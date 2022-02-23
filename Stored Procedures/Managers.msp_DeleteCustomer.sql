SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [Managers].[msp_DeleteCustomer]
@CustID int
AS

declare @lastname VARCHAR(64)
SELECT @lastname = LastName from  Snoopy.tbl_Customers 
where CustomerID = @CustID

IF @lastname IS NULL
BEGIN
	PRINT 'Customer does not exist'
	RETURN 1
END

PRINT 'Deleting Customer ' + (@lastname)


declare @ret int
set @ret = 0
BEGIN TRANSACTION trn_DeleteCustomer

BEGIN TRY  

	--assign all transaction to the new customer
	delete from Snoopy.tbl_CartediCredito
	where FK_CustomerTransactionID in (select customerTransactionID from  Snoopy.tbl_CustomerTransactions where CustomerID = @CustID)

	delete from Snoopy.tbl_Assegni
	where FK_EmissCustTransID in (select customerTransactionID from  Snoopy.tbl_CustomerTransactions where CustomerID = @CustID)

	delete from Snoopy.tbl_CustomerTransactionValues
	where customerTransactionID in (select customerTransactionID from  Snoopy.tbl_CustomerTransactions where CustomerID = @CustID)

	delete from  Snoopy.tbl_CustomerTransactions
	where CustomerID = @CustID

	update  Snoopy.tbl_Customers 
		set IDentificationID = null
	where CustomerID = @CustID

	delete from Snoopy.tbl_Identifications 
	where CustomerId  = @CustID

	delete from GoldenClub.tbl_Members 
	where CustomerId  = @CustID

	delete from GoldenClub.tbl_Cards 
	where CustomerId  = @CustID


	--assign all Documents to the new customer
	delete from Snoopy.tbl_IDDocuments
	where CustomerID = @CustID
	--assign all BankAccounts to the new customer
	delete from  Snoopy.tbl_CustomerBankAccounts
	where CustomerID = @CustID
	--assign all Registrations to the new customer
	delete from  Snoopy.tbl_Registrations
	where CustomerID = @CustID
	--assign all Pep-Cheks to the new customer
	delete from  Snoopy.tbl_PepChecks
	where CustomerID = @CustID



	--delete old Customer from the list
	delete from  GoldenClub.tbl_Members 
	where CustomerID = @CustID

	delete from  GoldenClub.tbl_Cards 
	where CustomerID = @CustID

	delete from  Snoopy.tbl_Customers 
	where CustomerID = @CustID

	COMMIT TRANSACTION trn_DeleteCustomer
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteCustomer		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
RETURN @ret
GO
