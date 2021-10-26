SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Snoopy].[usp_NewLRDMarkControlloSM] 
@IdentificID int,
@uaid	int,
@ora	datetime output
AS

if @IdentificID = null or not exists (select IdentificationID from Snoopy.tbl_Identifications where IdentificationID = @IdentificID)
begin
	raiserror('Invalid IdentificationID (%d) specified',16,1,@IdentificID)
	return (1)
end

if exists (select IdentificationID from Snoopy.tbl_Identifications where IdentificationID = @IdentificID and SMCheckUserAccessID is not null)
begin
	raiserror('Identification already checked',16,1)
	return (2)
end

if not exists (
	select UserAccessID from FloorActivity.tbl_UserAccesses 
	where UserAccessId = @uaid
	)
begin
	raiserror('UserAccesses %d does not exists',16,1,@uaid)
	return (5)
end

set @ora = GETUTCDATE()

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDMarkControlloSM

BEGIN TRY  



	update Snoopy.tbl_Identifications
	set SMCheckUserAccessID = @uaid,
	SMCheckTimeStampUTC = @ora
	where IdentificationID = @IdentificID

	exec GeneralPurpose.fn_UTCToLocal 1,@ora


	COMMIT TRANSACTION trn_NewLRDMarkControlloSM

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDMarkControlloSM
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
