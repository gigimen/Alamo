SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [FloorActivity].[usp_CreateUserAccess] 
@SiteID INT, 
@UserID INT, 
@UserGroupID INT, 
@AppID INT,
@UserAccessID INT OUTPUT
AS

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateUserAccess

BEGIN TRY  


	INSERT INTO FloorActivity.tbl_UserAccesses (SiteID,UserID,UserGroupID,ApplicationID) 
		VALUES(@SiteID,@UserID,@UserGroupID,@AppID)

	--store the user access
	set @UserAccessID = SCOPE_IDENTITY()


	COMMIT TRANSACTION trn_CreateUserAccess

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateUserAccess
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
