SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_CheckRipristinoAccepted]
@lfcyID int,
@RipAccepted int out,
@TransID int out,
@AcceptTimeLoc datetime out
AS
declare @StockID int
select @StockID = StockID from Accounting.tbl_LifeCycles where LifeCycleID = @lfcyID
if(@StockID is null)
begin
	raiserror('Must specify a valid LifeCycleID',16,-1)
	return (1)
end
if exists 
	(SELECT TransactionID FROM    Accounting.tbl_Transactions 
	        INNER JOIN CasinoLayout.OperationTypes ON CasinoLayout.OperationTypes.OpTypeID = Accounting.tbl_Transactions.OpTypeID 
	WHERE   Accounting.tbl_Transactions.DestStockID = @StockID 	
		--destination is the stock and operation is a ripristino
		and CasinoLayout.OperationTypes.OpTypeID = 5 -- 'Ripristino')
		--it has been accepted since the destination life cycle has been marked
		and Accounting.tbl_Transactions.DestLifeCycleID = @lfcyID
		AND (Accounting.tbl_Transactions.TrCancelID is null)
	)
	set @RipAccepted = 1
else
	set @RipAccepted = 0
if @RipAccepted = 1
	select 	@TransID = Accounting.tbl_Transactions.TransactionID,
		@AcceptTimeLoc = GeneralPurpose.fn_UTCToLocal(1,Accounting.tbl_Transactions.DestTime)
		FROM    Accounting.tbl_Transactions 
	    INNER JOIN CasinoLayout.OperationTypes ON CasinoLayout.OperationTypes.OpTypeID = Accounting.tbl_Transactions.OpTypeID 
	WHERE   Accounting.tbl_Transactions.DestStockID = @StockID 	
		--destination is the stock and operation is a ripristino
		and CasinoLayout.OperationTypes.OpTypeID = 5 --'Ripristino'
		--it has been accepted since the destination life cycle has been marked
		and Accounting.tbl_Transactions.DestLifeCycleID = @lfcyID
		AND (Accounting.tbl_Transactions.TrCancelID is null)
		
GO
GRANT EXECUTE ON  [Accounting].[usp_CheckRipristinoAccepted] TO [SolaLetturaNoDanni]
GO
