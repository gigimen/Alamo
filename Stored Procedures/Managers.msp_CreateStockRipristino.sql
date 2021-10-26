SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE  [Managers].[msp_CreateStockRipristino]
@StockID int
AS



/*

declare @StockID int
set @StockID = 41

--*/

DECLARE @err INT
declare @StockTypeID int
DECLARE @MSlfcyID INT, @compID int,@TransID INT,@SourceUserAccessID int
declare @g datetime
declare @tUTC datetime
declare @tLoc datetime


select @StockTypeID = StockTypeID from CasinoLayout.Stocks where StockID = @StockID


if not exists( select LifeCycleID from Accounting.tbl_LifeCycles where StockID = 31)
begin
	print 'Create Main stock life cycle'
	--open main stock lifecycle
--	execute @err = Accounting.usp_OpenLifeCycle 31,1,null,null,@MSlfcyID output,@MSLFSSID output,@g output,		@tLoc output,		@tUTC output

end
else
begin
	select @MSlfcyID = LifeCycleID from [Accounting].[fn_GetLastLifeCycleByStock] (GETDATE(),31)
	SELECT @SourceUserAccessID = UserAccessID,@g = GamingDate FROM Accounting.vw_AllStockLifeCycles WHERE LifeCycleID = @MSlfcyID
	
	print 'Main stock lifecycle id: ' + str(@MSlfcyID) + ' access  ' + STR(@SourceUserAccessID)
END


SELECT @compID = StockCompositionID FROM CasinoLayout.tbl_StockComposition_Stocks WHERE StockID = @StockID AND EndOfUseGamingDate IS NULL
IF @compID IS NULL OR NOT EXISTS
(
	SELECT DenoID FROM CasinoLayout.StockComposition_Denominations WHERE StockCompositionID = @compID AND InitialQty <> 0
)
BEGIN
	raiserror ('Stock (%d) has no valid composition!!',16,1,@StockID)
	RETURN 1
END


IF EXISTS
(
SELECT TransactionID FROM Accounting.vw_AllTransactions WHERE OpTypeID = 5 AND SourceGamingDate = @g AND DestStockID = @StockID
)
BEGIN
	raiserror ('Stock (%d) has already a ripristino defined!!',16,1,@StockID)
	RETURN 2
END

PRINT 'Stock composition is %d' + STR(@compID)

/*
		select 
		@transID ,
		DenoID,
		InitialQty,
		1.0,
		1
		FROM CasinoLayout.StockComposition_Denominations WHERE StockCompositionID = @compID AND InitialQty <> 0
*/


--first create the transaction


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateStockRipristino

BEGIN TRY 


	--we ave to create the transaction first
	set @tUTC = GetUTCDate()
	insert into Accounting.tbl_Transactions 
		(
			OpTypeID,
			SourceLifeCycleID,
			DestStockTypeID,
			DestStockID,
	--		DestLifeCycleID,
			SourceUserAccessID,
			SourceTime) 
	values(
				5		, --ripristino
				@MSlfcyID		,
				@StockTypeID	,
				@StockID		,
	--			@DestLifeCycleID	,
				@SourceUserAccessID		,
				@tUTC		
				)

	set @TransID = @@IDENTITY

	insert into Accounting.tbl_TransactionValues 
		(TransactionID,DenoID,Quantity,ExchangeRate,CashInbound)
	select 
		@transID ,
		DenoID,
		InitialQty,
		1.0,
		1
	FROM CasinoLayout.StockComposition_Denominations WHERE StockCompositionID = @compID AND InitialQty <> 0

	COMMIT TRANSACTION trn_CreateStockRipristino

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateStockRipristino	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
