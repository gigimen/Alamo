SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [FloorActivity].[usp_MarkUserAccess] 
@LifeCycleID INT,
@UserAccessID INT
AS

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_MarkUserAccess

BEGIN TRY  


	if EXISTS (SELECT UserAccessID FROM FloorActivity.tbl_UserAccesses 
		WHERE UserAccessID = @UserAccessID AND LifeCycleID IS null)
	begin
		UPDATE FloorActivity.tbl_UserAccesses
			SET LifeCycleID = @LifeCycleID 
			WHERE UserAccessID = @UserAccessID
	END
	ELSE if EXISTS (SELECT UserAccessID FROM FloorActivity.tbl_UserAccesses 
		WHERE UserAccessID = @UserAccessID AND LifeCycleID <> @LifeCycleID)
	BEGIN
		raiserror('Useraccess already assigned to another LifeCycleID',16,1)
	end

	COMMIT TRANSACTION trn_MarkUserAccess

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_MarkUserAccess
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
