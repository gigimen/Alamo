SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Accounting].[usp_OpenLifeCycle] 
@StockID int,
@UserAccessID int,
@ConfirmUserID int,
@ConfirmUserGroupID int,
@LFID int output,
@LFSSID int output,
@GamingDate datetime output,
@OpenTimeLoc datetime output,
@OpenTimeUTC datetime output
AS
declare @StockTypeID int
declare @StockCompositionID INT
DECLARE @Tag VARCHAR(16)

--get StockTypeID and @InitialReserve
select @StockTypeID = StockTypeID,@Tag=Tag
from CasinoLayout.Stocks 
where StockID = @StockID

--get current StockCompositionID for the specified stock 
select @StockCompositionID = StockCompositionID 
from CasinoLayout.[tbl_StockComposition_Stocks] 
where StockID = @StockID AND EndOfUseGamingDate IS null

if @StockCompositionID is null
begin
	raiserror('Stock %d has no StockComposition defined',16,1,@StockID)
	return (1)
end

if @GamingDate is null
	--set the gaming date in the database in local time
	set @GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
		GetUTCDate(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GetUTCDate(),GetDate()),
		@StockTypeID
		)

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateLifeCycle

BEGIN TRY



	--print 'Creating life cycle id'
	insert into Accounting.tbl_LifeCycles 
		(StockID,GamingDate,StockCompositionID) 
		VALUES (@StockID,@GamingDate,@StockCompositionID)

	SET @LFID = SCOPE_IDENTITY()
	select @GamingDate = GamingDate from Accounting.tbl_LifeCycles where LifeCycleID = @LFID
	--print 'New LifeCycleID is ' + str(@LFID) + ' for stock ' + str(@StockID) + ' GamingDate is ' + CONVERT(varchar(32),@GamingDate,113)

	EXECUTE Accounting.usp_CreateSnapShotXML 
		@LFID,
		@UserAccessID,
		@ConfirmUserID,
		@ConfirmUserGroupID,
		1, --APERTURA
		NULL, --values never stored in apertura!!!
		@LFSSID	output,
		@OpenTimeLoc output,
		@OpenTimeUTC output


	--if InitialReserve is defined mark it as the first progress of the gaming date
	if EXISTS (SELECT DenoID FROM CasinoLayout.StockComposition_Denominations WHERE StockCompositionID = @StockCompositionID AND IsRiserva = 1)
	begin
		insert into Accounting.tbl_Progress 
			(LifeCycleID,DenoID,Quantity,ExchangeRate,StateTime,UserAccessID) 
			SELECT 
				@LFID,
				DenoID,
				InitialQty,
				1,--always 1
				@OpenTimeUTC,
				@UserAccessID
			FROM CasinoLayout.StockComposition_Denominations WHERE StockCompositionID = @StockCompositionID AND IsRiserva = 1
	END

    --check if a ripristino exists and accept it
	IF EXISTS (SELECT TransactionID from Accounting.vw_AllTransactions
				 where DestStockID = @StockID
				 and OpTypeID = 5 --ripristino operation
				 and DestLifeCycleID is null --transaction is pending if DestLifeCycleID is null 
		)
	BEGIN

		DECLARE @transID INT,@AcceptTimeLoc datetime,@AcceptTimeUTC DATETIME

		SELECT @transID = TransactionID from Accounting.vw_AllTransactions
		where DestStockID = @StockID
		and OpTypeID = 5 --ripristino operation
		and DestLifeCycleID is null --transaction is pending if DestLifeCycleID is null 

		EXECUTE @ret = [Accounting].[usp_AcceptTransaction] 
		   @transID
		  ,@LFID
		  ,@UserAccessID
		  ,@ConfirmUserID
		  ,@ConfirmUserGroupID
		  ,@AcceptTimeLoc OUTPUT
		  ,@AcceptTimeUTC OUTPUT
                
	END



	/*
	if @StockID = 46 --if we are opening main cassa
	begin
	--we have to get all assegni on our bilancio
		declare  @emmTrID int
		declare  @redemtrID int
		declare @ret int
		set @ret = CURSOR_STATUS ('global','ass_cursor')
		if @ret > -3
		begin
			print 'deallocting ass_cursor'
			DEALLOCATE ass_cursor
		end
		DECLARE ass_cursor CURSOR
			FOR
			select EmissCustTransID,RedemCustTransID
			
			from Snoopy.AllAssegni
			where GamingDate = @GamingDate
		OPEN ass_cursor
		FETCH NEXT FROM ass_cursor INTO @emmTrID,@redemtrID
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
			if @emmTrID is not null
				update CustomerTransactions 
					set SourceLifeCycleID = @LFID
				where CustomerTransactionID = @emmTrID

			if @redemtrID is not null
				update CustomerTransactions 
					set SourceLifeCycleID = @LFID
				where CustomerTransactionID = @redemtrID
			
		FETCH NEXT FROM ass_cursor INTO @emmTrID,@redemtrID
		END
		set @ret = CURSOR_STATUS ('global','ass_cursor')
		if @ret > -3
		begin
			print 'deallocting ass_cursor'
			DEALLOCATE ass_cursor
		end
	end
	*/
	COMMIT TRANSACTION trn_CreateLifeCycle

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateLifeCycle
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	return @ret
END CATCH


--in case openning an live game table
IF @StockTypeID = 1 --LEFT(@Tag,2) = 'AR' or LEFT(@Tag,2) = 'BJ'
BEGIN
	DECLARE @retMsg NVARCHAR(4000),@table NVARCHAR(4000)

	SELECT @retMsg = [GeneralPurpose].[fn_OpenTableOnCISDisplay] (@Tag)


	--clear also table results
	SELECT @retMsg = [GeneralPurpose].[fn_ClearTableResultsOnCISDisplay] (@Tag)
END

RETURN @ret
GO
