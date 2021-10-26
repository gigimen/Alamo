SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [Managers].[msp_DeleteDeposito] 
@DepositoID int
AS

declare @ret int
set @ret = 0

if not @DepositoID is null
begin
	
	declare @DepoCustTransID int,@PrelevCustTransID int
	SELECT @DepoCustTransID= [DepoCustTransID]
		  ,@PrelevCustTransID = [PrelevCustTransID]
	  FROM Snoopy.tbl_Depositi
	where [DepositoID] = @DepositoID
      



	BEGIN TRANSACTION trn_DeleteDeposito

	BEGIN TRY  

		--leva la Transazione di prelievo
		if @PrelevCustTransID is not null
		begin

			UPDATE Snoopy.tbl_Depositi SET [PrelevCustTransID] = null where [DepositoID] = @DepositoID
		
			delete from Snoopy.tbl_CustomerTransactionValues where CustomerTransactionID = @PrelevCustTransID

			delete from Snoopy.tbl_CustomerTransactions where CustomerTransactionID = @PrelevCustTransID

		end

		--cancella prima il deposito
		DELETE from Snoopy.tbl_Depositi where [DepositoID] = @DepositoID

		--e la sua Transazione di versamento
		delete from Snoopy.tbl_CustomerTransactionValues where CustomerTransactionID = @DepoCustTransID

		delete from Snoopy.tbl_CustomerTransactions where CustomerTransactionID = @DepoCustTransID




		COMMIT TRANSACTION trn_DeleteDeposito

	END TRY  
	BEGIN CATCH  
		ROLLBACK TRANSACTION trn_DeleteDeposito
		set @ret = error_number()
		declare @dove as varchar(50)
		select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
		EXEC [Managers].[msp_HandleError] @dove
	END CATCH
end

return @ret
GO
