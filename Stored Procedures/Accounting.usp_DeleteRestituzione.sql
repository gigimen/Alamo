SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE   PROCEDURE [Accounting].[usp_DeleteRestituzione]
@transID				INT
AS

IF @transID IS NULL OR NOT EXISTS (SELECT [PK_RestituzioneID] FROM [Snoopy].[tbl_CustomerRestituzioni] WHERE [PK_RestituzioneID] = @transID AND RestGamingDate IS NOT null)
BEGIN
	RAISERROR('Invalid restituzione specified ',16,1)
	RETURN 1
END

DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_DeleteRestituzione

BEGIN TRY  

--first delete restituzione
	UPDATE [Snoopy].[tbl_CustomerRestituzioni]
		SET RestGamingDate = NULL, RestUserAccessID = NULL, RestTimeStampUTC = NULL
	WHERE [PK_RestituzioneID] = @transID


	COMMIT TRANSACTION trn_DeleteRestituzione

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteRestituzione	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
