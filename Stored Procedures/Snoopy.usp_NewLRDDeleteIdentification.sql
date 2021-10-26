SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Snoopy].[usp_NewLRDDeleteIdentification]
@UserAccessID int,
@CustID int
AS
--check input values
--if customer already in the list
if not exists (select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID)
begin
	raiserror('Invalid customer id (%d) specified',16,1,@CustID)
	return (2)
end

--if the customer has some deposito cancel deposito first
if exists(SELECT DepositoID
FROM         Snoopy.vw_AllDepositi
WHERE     (DepOffID IS NULL)
AND CustomerID = @CustID)
begin
	raiserror('Customer (%d) owns a deposito',16,1,@CustID)
	return (3)
END

--if the customer has been already in golden club signal it
if exists(SELECT CustomerID
FROM        GoldenClub.tbl_Members
WHERE     (GoldenClubCardID IS not NULL)
AND CustomerID = @CustID)
begin
	raiserror('Customer (%d) fa parte del GOLDEN CLUB!!!',16,1,@CustID)
	return (4)
end

declare @identID int
declare @iddocid int
declare @idregid int

--look for identification of the customer
select @identID = IdentificationID  
from Snoopy.tbl_Customers 
where CustomerID = @CustID

if @identID is null 
begin
	raiserror('Customer (%d) is not identified!!',16,1,@CustID)
	return (5)
end

--look for the identificatin document and registration
select 	@iddocid = i.IdDocumentID,
	@idregid = i.RegID
from Snoopy.tbl_Identifications i
where IdentificationID = @identID

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDDeleteIdentification

BEGIN TRY  




	--cancel identification data reference
	update Snoopy.tbl_Customers
		set IdentificationID = null
	where CustomerID = @CustID


	--first create a new CancelActions 
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GetUTCDate(),@UserAccessID)

	declare @cancID int
	set @cancID = @@IDENTITY

	--cancel identification
	update Snoopy.tbl_Identifications 
	set CancelId = @cancID
	where IdentificationID = @identID

	--mark as cancelled golden club participation and unlink any possible goldenclub card
	update GoldenClub.tbl_Members
		set CancelID = @cancID,GoldenClubCardID = null
	where CustomerID = @CustID

	--mark as cancelled golden club card
	update GoldenClub.tbl_Cards
		set CancelID = @cancID
	where CustomerID = @CustID



	declare @attr varchar(256)

	--cancel identification registration
	if @idregid is not null
		exec [Snoopy].[usp_NewLRDDeleteRegistration] @idregid,@UserAccessID


	set @attr = 'CustID=''' + cast(@CustID as varchar(16)) + ''''

	declare @RegExists int
	set @RegExists = 0

	--check if a registration exists for that customer
	if exists (select CustomerTransactionID from Snoopy.tbl_CustomerTransactions where CustomerID = @CustID and CustTRCancelID is null)
	--or maybe any assegno
	or exists (select PK_AssegnoID from Snoopy.tbl_Assegni where FK_IDDocumentID = @iddocid)
	or exists (select CreditCardTransID from Snoopy.tbl_CartediCredito where FK_IDDocumentID = @iddocid)
		set @RegExists = 1


	--if no registration exists
	--we can also delete the customer
	if @RegExists = 0
	begin
		--update the customer table
		update Snoopy.tbl_Customers
			set CustCancelID = @cancID
		where CustomerID = @CustID
		set @attr = @attr + ' Deleted=''1'''		
	end
	else
		set @attr = @attr + ' Deleted=''0'''		


	execute [GeneralPurpose].[usp_BroadcastMessage] 'DeleteIdentific',@attr

	COMMIT TRANSACTION trn_NewLRDDeleteIdentification

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDDeleteIdentification
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
