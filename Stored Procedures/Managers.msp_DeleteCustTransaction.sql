SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [Managers].[msp_DeleteCustTransaction] 
@transID int
AS
if not @transID is null
begin
	declare @opName varchar(50),@err int
	select @opName = CasinoLayout.OperationTypes.FName 
		from  Snoopy.tbl_CustomerTransactions inner join CasinoLayout.OperationTypes 
		on  Snoopy.tbl_CustomerTransactions.OpTypeID = CasinoLayout.OperationTypes.OpTypeID
		where CustomerTransactionID = @transID
	print 'Deleting customer transaction ' + @opName + ' (' + str(@transID) + ')'

	begin transaction  DeleteCustTransaction
	delete from Snoopy.tbl_Assegni where FK_EmissCustTransID = @transID OR FK_RedemCustTransID = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end
	
	DELETE from snoopy.tbl_CartediCredito where FK_CustomerTransactionID = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end
	
	DELETE from Snoopy.tbl_Depositi where [DepoCustTransID] in (select CustomerTransactionID from Snoopy.tbl_CustomerTransactions where CustomerTransactionID = @transID)
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end
	
	delete from Snoopy.tbl_CustomerTransactionValues where CustomerTransactionID = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end

	delete FROM FloorActivity.tbl_CustomerTransactionModifications where [CustomerTransactionID] = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end

	update Snoopy.tbl_Depositi set PrelevCustTransID = null where PrelevCustTransID = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end
	update Snoopy.tbl_Depositi set DepoCustTransID = null where DepoCustTransID = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end

	delete Snoopy.tbl_Bonifici where [OrderCustTransID] = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end

	delete from Snoopy.tbl_CustomerTransactions where  CustomerTransactionID = @transID
	SELECT @err = @@ERROR IF (@ERR <> 0) begin	ROLLBACK TRANSACTION DeleteCustTransaction	return @ERR		end

	Commit transaction DeleteCustTransaction


end


GO
