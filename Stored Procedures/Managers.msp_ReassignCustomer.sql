SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   PROCEDURE [Managers].[msp_ReassignCustomer]
@FromCustID INT,
@ToCustID INT
AS



--check input values
if not exists (select CustomerID from Snoopy.tbl_Customers where CustomerId in (@FromCustID,@ToCustID))
begin
	raiserror('Invalid customerid specified',16,1)
	RETURN (2)
END



DECLARE @ret INT

SET @ret = 0

BEGIN TRANSACTION trn_ReassignCustID

BEGIN TRY  

	--remove his parteciptaion to the goldenclub
	if  exists (select CustomerID from GoldenClub.tbl_Members where CustomerId = @FromCustID and GoldenClubCardId is not null)
	BEGIN

		print 'customer was a golden!!'

		--unassign the card 
		UPDATE GoldenClub.tbl_Cards
			SET CustomerID = NULL
		WHERE CustomerId = @FromCustID

		--delete customer card info
		DELETE FROM GoldenClub.tbl_CustomerCardsHistory WHERE CustomerID =  @FromCustID

		DELETE FROM GoldenClub.tbl_Members where CustomerId = @FromCustID

	END


	if exists (
		select CustomerID from Snoopy.tbl_Customers 
		where CustomerId  = @FromCustID
		and IdentificationID is not null)
	begin
		--raiserror('Cannot cancel customer %d because is identified',16,1,@FromCustID)
		--return (4)
		print 'customer cancelled was identified!!'
		declare @ideID int
		select @ideID = IdentificationID from Snoopy.tbl_Customers 
		where CustomerId  = @FromCustID

		update Snoopy.tbl_Customers 
			set IdentificationID = null
		where CustomerId  = @FromCustID
	
		--delete the identification!!
		delete from Snoopy.tbl_Identifications
		where CustomerId  = @FromCustID and IdentificationID = @ideID

	END




	declare @minInsertTime datetime


	select @minInsertTime = min(InsertDate)  from Snoopy.tbl_Customers 
	where CustomerID in (@FromCustID,@ToCustID)


	--assign all transaction to the new customer
	update Snoopy.tbl_CustomerTransactions
		set CustomerID = @ToCustId
		where CustomerID = @FromCustID


	--assign all euro transaction to the new customer
	update Accounting.tbl_EuroTransactions
		set CustomerID = @ToCustId
		where CustomerID = @FromCustID

	--assign all Documents to the new customer
	update Snoopy.tbl_IDDocuments
		set CustomerID = @ToCustId
		where CustomerID = @FromCustID

	--assign all BankAccounts to the new customer
	UPDATE Snoopy.tbl_CustomerBankAccounts
		SET CustomerID = @ToCustId
		WHERE CustomerID = @FromCustID

	--assign all Registrations to the new customer
	UPDATE Snoopy.tbl_Registrations
		SET CustomerID = @ToCustId
		WHERE CustomerID = @FromCustID

	--assign all Pep-Cheks to the new customer
	UPDATE Snoopy.tbl_PepChecks
		SET CustomerID = @ToCustId
		WHERE CustomerID = @FromCustID


	--assegni all premi to the old one
	UPDATE Marketing.tbl_AssegnazionePremi
		SET CustomerID = @ToCustId
		WHERE CustomerID = @FromCustID


		--assign all  chiavi
	UPDATE 	[Yogi].[tbl_Occurred]
		SET FK_CustomerID = @ToCustId
		WHERE FK_CustomerID = @FromCustID


	--remove it from golden club
	DELETE FROM GoldenClub.tbl_Cards 
		WHERE CustomerId = @FromCustID
	
	DELETE FROM GoldenClub.tbl_Members 
		WHERE CustomerId = @FromCustID
	
	--delete old Customer from the list
	DELETE Snoopy.tbl_Customers 
		WHERE CustomerId = @FromCustID

	--save the insert time of the first one
	UPDATE Snoopy.tbl_Customers 
	SET [InsertDate] = @minInsertTime
	WHERE CustomerId = @ToCustID

	COMMIT TRANSACTION trn_ReassignCustID
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ReassignCustID	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret

GO
