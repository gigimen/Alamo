SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [Managers].[msp_DeleteTransaction] 
@transID int
AS
if not @transID is null
begin
	declare @opName varchar(50)
	select @opName = CasinoLayout.OperationTypes.FName 
		from Accounting.tbl_Transactions inner join CasinoLayout.OperationTypes 
		on Accounting.tbl_Transactions.OpTypeID = CasinoLayout.OperationTypes.OpTypeID
		where TransactionID = @transID
	print 'Deleting transaction ' + @opName + ' (' + str(@transID) + ')'
	
	delete from Accounting.tbl_Transaction_Confirmations where TransactionID = @transID 
	delete from Accounting.tbl_TransactionValues where TransactionID  = @transID

	delete FROM FloorActivity.tbl_TransactionModifications where TransactionID = @transID 
	delete from Accounting.tbl_Transactions WHERE TransactionID = @transID 


end

GO
