SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_CreateRipristinoSMT] 
@UserAccessID			int,
@MSLFID					INT,
@consegnaTransID		int output,
@ripristinoTransID		int OUTPUT,
@ritTransTime			DATETIME output
AS
/*


declare @UserAccessID			int,
@MSLFID					INT,
@consegnaTransID		int ,
@ripristinoTransID		int ,
@ritTransTime			DATETIME 


set @MSLFID=179800

--*/
if @MSLFID is null
begin
	raiserror('NULL @@MSLFID specified',16,1)
	return 1
END

DECLARE @GamingDate DATETIME,@StockID int,@StockTypeID INT,@SourceLifeCycleID INT,@DestLifeCycleID INT

--apertura snapshot must exsist for the specified lifecycelid
select @GamingDate = lf.GamingDate 
from Accounting.tbl_LifeCycles lf
inner join Accounting.tbl_Snapshots ap on ap.LifeCycleID = lf.LifeCycleID and ap.SnapshotTypeID = 1 and ap.LCSnapShotCancelID is null
left outer join Accounting.tbl_Snapshots ch on ch.LifeCycleID = lf.LifeCycleID and ch.SnapshotTypeID = 3 and ch.LCSnapShotCancelID is null
where lf.LifeCycleID = @MSLFID and lf.StockID = 31 and ch.LCSnapShotCancelID is null


if @GamingDate IS NULL
begin
	raiserror('Invalid @@MSLFID specified',16,1)
	return 1
END

SELECT @consegnaTransID = [Accounting].[fn_GetConsegnaSMTTransID] (@gamingdate)

IF @consegnaTransID IS NULL
begin
	--nothing to be repristinated
	SET @ripristinoTransID = null
	return 0
END


--look for Consegna of the same GamingDate of the MS			
SELECT  @StockID				= StockID,
		@StockTypeID			= StockTypeID,
		@SourceLifeCycleID		= LifeCycleID,
		@DestLifeCycleID		= ConsegnaDestLifeCycleID,
		@ripristinoTransID		= RIPTransactionID
FROM  [Accounting].[vw_AllChiusuraConsegnaRipristino] 
WHERE GamingDate = @GamingDate
	AND StockID  = 30 --source stock SMT


SELECT @consegnaTransID AS '@consegnaTransID'
SELECT  @DestLifeCycleID AS '@DestLifeCycleID'
SELECT  @ripristinoTransID AS '@ripristinoTransID'





declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateRipristinoSMT

BEGIN TRY  
	declare @AcceptTimeLoc datetime,@AcceptTimeUTC DATETIME
    
	--if not accepetd yet
	IF EXISTS (SELECT TransactionID FROM Accounting.vw_AllTransactions WHERE TransactionID = @consegnatransid AND DestLifeCycleID IS null)
	begin
		--accept Consegna transaction
		EXECUTE [Accounting].[usp_AcceptTransaction] 
			   @consegnatransid
			  ,@MSLFID
			  ,@UserAccessID
			  ,null --@ConfUserID
			  ,null --@ConfUserGroupID
			  ,@AcceptTimeLoc OUTPUT
			  ,@AcceptTimeUTC OUTPUT
	END
    
	--create ripristino transaction
	IF @ripristinoTransID IS NULL
	BEGIN
		SET @ritTransTime = GETUTCDATE()
		INSERT INTO Accounting.tbl_Transactions
				([OpTypeID]
				,[SourceLifeCycleID]
				,[DestStockID]
				,[SourceTime]
				,[DestStockTypeID]
				,[SourceUserAccessID])
 
		values(
				5,--@OpTypeID	,
				@MSLFID			,
				@StockID		,
				@ritTransTime	,
				@StockTypeID	,
				@UserAccessID		
				)

		set @ripristinoTransID = @@IDENTITY

		insert into Accounting.tbl_TransactionValues 
		(
			TransactionID,
			DenoID,
			Quantity,
			ExchangeRate,
			CashInbound
		)
		--	values( @DenoID,@qty,@exchange,@CashInbound)
/*
		declare @SourceLifeCycleID int,@StockID int


		set @SourceLifeCycleID = 179567
		set @StockID = 30

		select 
			c.*,
			[Accounting].[fn_TableCalculateRipristino](
					c.[DenoID],
					isnull(ch.Chiusura,0)+isnull(ch.Consegna,0),
					c.[InitialQty],
					c.[ModuleValue]
				) as Ripristinato,
			1.0, --exchange rate
			1 --rispristino is cashinbound
		from [CasinoLayout].[vw_AllStockCompositions] c
		left outer join 
		( select Chiusura,Consegna,DenoID from [Accounting].[vw_AllChiusuraConsegnaDenominations]
			where LifeCycleID = @SourceLifeCycleID
		) ch on ch.DenoID = c.DenoID  
		where c.StockID = @StockID and 
			[Accounting].[fn_TableCalculateRipristino](
						c.[DenoID],
						isnull(ch.Chiusura,0)+isnull(ch.Consegna,0),
						c.[InitialQty],
						c.[ModuleValue]) > 0
		and c.EndOfUseGamingDate is null
		




*/


		select 
			@ripristinoTransID ,
			c.DenoID,
			[Accounting].[fn_TableCalculateRipristino](
					c.[DenoID],
					isnull(ch.Chiusura,0),
					c.[InitialQty],
					c.[ModuleValue]
				),
			1.0, --exchange rate
			1 --rispristino is cashinbound
		from [CasinoLayout].[vw_AllStockCompositions] c
		left outer join 
		( select Chiusura,Consegna,DenoID from [Accounting].[vw_AllChiusuraConsegnaDenominations]
			where LifeCycleID = @SourceLifeCycleID
		) ch on ch.DenoID = c.DenoID  
		where c.StockID = @StockID and 
			[Accounting].[fn_TableCalculateRipristino](
						c.[DenoID],
						isnull(ch.Chiusura,0),
						c.[InitialQty],
						c.[ModuleValue]) > 0
		and c.EndOfUseGamingDate is null


	END
	ELSE
    BEGIN
		SELECT 
			@ritTransTime		= SourceTimeLoc 
		FROM Accounting.vw_AllTransactions 
		WHERE TransactionID = @ripristinoTransID --same lfid
		AND DestStockID			= @StockID --same StockID : SMT
		AND OpTypeID			= 5 --only ripristino operations
		

/*
		select 
			@ripristinoTransID ,
			c.DenoID,
			[Accounting].[fn_TableCalculateRipristino](
					c.[DenoID],
					isnull(ch.Chiusura,0),
					c.[InitialQty],
					c.[ModuleValue]
				),
			1.0, --exchange rate
			1 --rispristino is cashinbound
		from [CasinoLayout].[vw_AllStockCompositions] c
		left outer join 
		( select Chiusura,Consegna,DenoID from [Accounting].[vw_AllChiusuraConsegnaDenominations]
			where LifeCycleID = @SourceLifeCycleID
		) ch on ch.DenoID = c.DenoID  
		where c.StockID = @StockID and 
			[Accounting].[fn_TableCalculateRipristino](
						c.[DenoID],
						isnull(ch.Chiusura,0),
						c.[InitialQty],
						c.[ModuleValue]) > 0
		and c.EndOfUseGamingDate is null
*/		
	END
    
   
    SET @ritTransTime = GeneralPurpose.fn_UTCToLocal(1,@ritTransTime)

	COMMIT TRANSACTION trn_CreateRipristinoSMT

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateRipristinoSMT
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
