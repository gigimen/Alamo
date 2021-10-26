SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   PROCEDURE [Accounting].[usp_DeleteDenaroTrovato]
@pk_DenarotrovatoID				INT
AS

IF @pk_DenarotrovatoID Is NULL OR NOT EXISTS (select PK_DenaroTrovatoID FROM [Accounting].[tbl_DenaroTrovato] WHERE PK_DenaroTrovatoID = @pk_DenarotrovatoID)
begin
	raiserror('Invalid @@pk_DenarotrovatoID specified ',16,1)
	RETURN 1
END

--se esiste la restituzione gia avvenuta abortisci
IF EXISTS ( SELECT [PK_RestituzioneID]  FROM [Snoopy].[tbl_CustomerRestituzioni]	
WHERE [FK_DenaroTrovatoID] = @pk_DenarotrovatoID AND RestGamingDate IS NOT null)
begin
	raiserror('La registrazione %d è già stata restituita',16,1,@pk_DenarotrovatoID)
	RETURN 1
END

DECLARE @ret INT
set @ret = 0

BEGIN TRANSACTION trn_DeleteDenaroTrovato

BEGIN TRY  

--first delete restituzione
	DELETE  FROM [Snoopy].[tbl_CustomerRestituzioni]	
	WHERE [FK_DenaroTrovatoID] = @pk_DenarotrovatoID

--then delete from [Accounting].[tbl_DenaroTrovato] 
	DELETE FROM [Accounting].[tbl_DenaroTrovato]
	WHERE [PK_DenaroTrovatoID] = @pk_DenarotrovatoID


	COMMIT TRANSACTION trn_DeleteDenaroTrovato

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteDenaroTrovato	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
