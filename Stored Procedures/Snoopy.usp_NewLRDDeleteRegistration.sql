SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [Snoopy].[usp_NewLRDDeleteRegistration]
@RegID int,
@UserAccessID int
AS
BEGIN TRANSACTION trn_NewLRDDeleteRegistration

BEGIN TRY  

declare @ret int
set @ret = 0

if exists 
	(
	select RegID from Snoopy.tbl_Registrations 
		where RegID = @RegID
		and CancelID is null
	)
begin
	declare @cancID INT


	--first create a new CustTrCancelID 
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GetUTCDate(),@UserAccessID)
	
	set @cancID = SCOPE_IDENTITY()

	--update the Chiusura snapshot
	update Snoopy.tbl_Registrations
		set CancelID = @cancID
		where RegID = @RegID
	
	
	
	declare @attr varchar(256)
	set @attr = 'RegID=''' + cast(@RegID as varchar(16)) + ''''
	execute [GeneralPurpose].[usp_BroadcastMessage] 'DeleteRegistration',@attr
end



	COMMIT TRANSACTION trn_NewLRDDeleteRegistration

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDDeleteRegistration
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
