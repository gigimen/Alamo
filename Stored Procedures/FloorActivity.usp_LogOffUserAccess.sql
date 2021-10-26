SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [FloorActivity].[usp_LogOffUserAccess] 
@UserAccessID INT,
@bForced INT
AS

if not exists( select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID(%d) specified',16,1,@UserAccessID)
	return(0)
END
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_LogOffUserAccess

BEGIN TRY  


IF @bForced = 1
	UPDATE FloorActivity.tbl_UserAccesses
	SET LogoutDate = GetUTCDate(),LogoutForced = 1
	WHERE UserAccessID = @UserAccessID
else
	UPDATE FloorActivity.tbl_UserAccesses
	SET LogoutDate = GetUTCDate() 
	WHERE UserAccessID = @UserAccessID



	COMMIT TRANSACTION trn_LogOffUserAccess

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_LogOffUserAccess
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
