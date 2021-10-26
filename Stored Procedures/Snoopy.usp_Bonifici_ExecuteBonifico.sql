SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Snoopy].[usp_Bonifici_ExecuteBonifico]
@BonificoID INT,
@UserAccessID INT,
@ExecTime DATETIME OUTPUT
AS


--first some check on parameters
IF NOT EXISTS (SELECT UserAccessID FROM FloorActivity.tbl_UserAccesses WHERE UserAccessID = @UserAccessID)
BEGIN
	raiserror('Invalid UserAccessID (%d) specified',16,1,@UserAccessID)
	RETURN 1
END

IF NOT EXISTS (SELECT BonificoID FROM Snoopy.tbl_Bonifici WHERE BonificoID = @BonificoID)
BEGIN
	RAISERROR('Invalid BonificoID (%d) specified',16,1,@BonificoID)
	RETURN 2
END
IF EXISTS (SELECT BonificoID FROM Snoopy.tbl_Bonifici WHERE BonificoID = @BonificoID AND ExecTimeStampUTC IS NOT NULL)
BEGIN
	RAISERROR('Bonifico (%d) already executed!',16,1,@BonificoID)
	RETURN 2
END

DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_Bonifici_ExecuteBonifico

BEGIN TRY  



	SET @ExecTime = GETUTCDATE()

	UPDATE Snoopy.tbl_Bonifici
	   SET [ExecTimeStampUTC] = @ExecTime
		  ,[ExecUserAccessID] = @UserAccessID
	 WHERE BonificoID = @BonificoID




	SET @ExecTime = GeneralPurpose.fn_UTCToLocal(1,@ExecTime)

	COMMIT TRANSACTION trn_Bonifici_ExecuteBonifico

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_Bonifici_ExecuteBonifico
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret

GO
