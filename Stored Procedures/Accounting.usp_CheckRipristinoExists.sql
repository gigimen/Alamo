SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE  [Accounting].[usp_CheckRipristinoExists]
@StockID int,
@RipExists int out,
@TransID int out
AS
--first check that a ripristino that has to be accepted exists
declare @count int
SELECT @count = count(*) FROM Accounting.tbl_Transactions 
	        INNER JOIN CasinoLayout.OperationTypes ON CasinoLayout.OperationTypes.OpTypeID = Accounting.tbl_Transactions.OpTypeID 
	WHERE   Accounting.tbl_Transactions.DestStockID = @StockID 	
		--destination is the stock and operation is a ripristino
		and CasinoLayout.OperationTypes.OpTypeID = 5 -- 'Ripristino'
		--still has to be accepted
		and Accounting.tbl_Transactions.DestLifeCycleID is null
		AND (Accounting.tbl_Transactions.TrCancelID is null)
if @count = 1
begin
	set @RipExists = 1
	SELECT  @TransID = Accounting.tbl_Transactions.TransactionID
	FROM Accounting.tbl_Transactions 
	        INNER JOIN CasinoLayout.OperationTypes ON CasinoLayout.OperationTypes.OpTypeID = Accounting.tbl_Transactions.OpTypeID 
	WHERE   Accounting.tbl_Transactions.DestStockID = @StockID 	
		--destination is the stock and operation is a ripristino
		and CasinoLayout.OperationTypes.OpTypeID = 5 -- 'Ripristino'
		--still has to be accepted
		and Accounting.tbl_Transactions.DestLifeCycleID is null
		AND (Accounting.tbl_Transactions.TrCancelID is null)
end
else if @count = 0
	set @RipExists = 0
else
begin
	raiserror('Attenzione piu'' di un ripristino pendente',16,1)
	return(1)
end

GO
GRANT EXECUTE ON  [Accounting].[usp_CheckRipristinoExists] TO [SolaLetturaNoDanni]
GO
