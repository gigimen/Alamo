SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

CREATE PROCEDURE [Snoopy].[usp_NewLRDIDDocument]
@CustID 		INT,
@Address 		varchar(256),
@DomicilioID 	int,
@Telefono 		varchar(32),
@UserAccessID 	int,
@citizenshipID 	int,
@docNumber 		VARCHAR(256),
@docTypeID 		INT,
@expirationDate datetime,
@IdDocID 		INT output
AS

--check input values
declare @userID int
select @userID = UserID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID


if @userID is null
begin
	raiserror('Invalid user access specified',16,1)
	return (2)
end
if @docTypeID is null or not exists (select IDDocTypeID from Snoopy.tbl_IDDocTypes where IDDocTypeID = @docTypeID)
begin
	raiserror('Invalid IDDocTypeID specified',16,1)
	return (2)
end
if @domicilioID is null or not exists (select NazioneID from Snoopy.tbl_Nazioni where NazioneID = @domicilioID)
begin
	raiserror('Invalid DomicilioID specified',16,1,@domicilioID)
	return (2)
end
if @citizenshipID is null or not exists (select NazioneID from Snoopy.tbl_Nazioni where NazioneID = @citizenshipID)
begin
	raiserror('Invalid CitizenshipID specified',16,1,@citizenshipID)
	return (2)
end
if @CustID is null
begin
	raiserror('Invalid LastName specified',16,1)
	return (2)
end
if @Address is null or len(@Address) = 0
begin
	raiserror('Invalid Address specified',16,1)
	return (2)
end
if @docNumber is null or len(@docNumber) = 0
begin
	raiserror('Invalid docNumber specified',16,1)
	return (2)
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDIDDocument

BEGIN TRY  


	if @IdDocID is null --if we did not provided a document
	begin
		--create a new document identification
	--		print 'Creating new document'
		insert into Snoopy.tbl_IDDocuments
			(
			CustomerID,
			IDDocTypeID,
			ExpirationDate,
			DocNumber,
			CitizenshipID,
			Address,
			DomicilioID,
			UserAccessID)
		VALUES	(
			@CustID,
			@docTypeID,
			@expirationDate,
			RTRIM(@docNumber),
			@citizenshipID,
			RTRIM(@Address),
			@DomicilioID,
			@UserAccessID
			)
	
		set @IdDocID = SCOPE_IDENTITY()
	end
	else --otherwise update document information
	begin
	--		print 'Updating existing document ' + cast(@IdDocID as varchar(32))

		update Snoopy.tbl_IDDocuments
			set CustomerID	= @CustID,
			IDDocTypeID		= @docTypeID,
			ExpirationDate	= @expirationDate,
			DocNumber		= RTRIM(@docNumber),
			CitizenshipID	= @citizenshipID,
			[Address]		= RTRIM(@Address),
			DomicilioID		= @DomicilioID,
			UserAccessID	= @UserAccessID	
		where IDDocumentID	= @IdDocID

	end	

	COMMIT TRANSACTION trn_NewLRDIDDocument

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDIDDocument
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret

GO
