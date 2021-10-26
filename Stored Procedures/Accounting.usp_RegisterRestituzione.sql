SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   PROCEDURE [Accounting].[usp_RegisterRestituzione]
@RestituzioneID			INT,
@UserAccessID			INT,
@lfid					INT,
@restOraLoc				DATETIME OUTPUT
AS

IF @RestituzioneID IS NULL OR EXISTS (SELECT [PK_RestituzioneID] FROM [Snoopy].[tbl_CustomerRestituzioni] WHERE [PK_RestituzioneID] = @RestituzioneID AND RestGamingDate IS NOT null)
BEGIN
	RAISERROR('NULL restituzione specified or restituzione già fatta!',16,1)
	RETURN 1
END

IF @UserAccessID IS NULL OR NOT EXISTS (SELECT UserAccessID FROM FloorActivity.tbl_UserAccesses WHERE UserAccessID = @UserAccessID)
BEGIN
	RAISERROR('NULL @UserAccessID specified or doen not exists',16,1)
	RETURN 1
END


DECLARE @ret INT,@gamingdate datetime
SET @ret = 0


SELECT @gamingdate = gamingDate FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @lfid
IF @gamingdate IS NULL
BEGIN
	RAISERROR('Invalif LifecycleID specified',16,1)
	RETURN 1
END

SELECT @restOraLoc = getutcdate()
BEGIN TRANSACTION trn_RegisterRestituzione

BEGIN TRY  

	UPDATE [Snoopy].[tbl_CustomerRestituzioni]
		SET RestGamingDate = @gamingdate, 
		RestUserAccessID = @UserAccessID, 
		RestTimeStampUTC = @restOraLoc
	WHERE [PK_RestituzioneID] = @RestituzioneID


	COMMIT TRANSACTION trn_RegisterRestituzione

	SELECT @restOraLoc = GeneralPurpose.fn_UTCToLocal(1,@restOraLoc)

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RegisterRestituzione
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
