SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [Managers].[msp_DeleteRirpristino] 
@transID int
AS
if not @transID is null
begin
	declare @GamingDate DATETIME,@Tag VARCHAR(32),@StockID int
	select @GamingDate = SourceGamingDate,@Tag = DestStockTag,@StockID = DestStockID
	from Accounting.vw_AllTransactionsEx
	WHERE TransactionID = @transID AND OpTypeID = 5 --ripristino


	declare @constransid int
	select @constransid = TransactionID 
	from Accounting.vw_AllTransactions 
	where SourceStockID = @StockID 
	and  SourceGamingDate = @GamingDate
	and OpTypeID = 6 --Consegna

	IF @GamingDate IS NULL OR @StockID IS null
	begin
		raiserror('transaction (%d) is not a ripristino',16,1,@transID)
		return (1)
	end

	IF @constransid IS null
	begin
		raiserror('Non esiste la Consegna dello stock (%d) ',16,1,@StockID)
		return (1)
	end

	print 'Deleting ripritino of ' + @Tag + ' (' + str(@transID) + ')'
	
	delete from Accounting.tbl_Transaction_Confirmations where TransactionID = @transID 
	delete from Accounting.tbl_TransactionValues where TransactionID  = @transID

	delete FROM FloorActivity.tbl_TransactionModifications where TransactionID = @transID 
	
	delete from Accounting.tbl_Transactions WHERE TransactionID = @transID 

	--unaccept Consegna


	--reset Consegna to unaccepted
	update Accounting.tbl_Transactions
		set DestTime = null,
		DestLifeCycleID = null,
		DestUserAccessID = null
	where TransactionID = @constransid

	--remove also confirmation of Consegna acceptance
	delete from Accounting.tbl_Transaction_Confirmations 
		where TransactionID = @constransid
		and IsSourceConfirmation = 0


end
GO
