SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Managers].[msp_ExtractImage]
 @IMG_PATH VARBINARY(MAX),
 @fullPathName varchar(MAX)
AS

/*

 how to enable OLE on the server
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO

*/
DECLARE @ErrorNumber INT
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorProcedure NVARCHAR(126)
DECLARE @ErrorLine INT
DECLARE @ErrorMessage NVARCHAR(2048)

--For OLE Automation.
DECLARE @ObjectReturn INT
DECLARE @ObjectToken INT
DECLARE @ErrorSource VARCHAR(255)
DECLARE @ErrorDesc VARCHAR(255)

BEGIN TRY
    /* Create a file system object. */
    EXEC @ObjectReturn = master.sys.sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
    IF (@ObjectReturn <> 0)
        BEGIN
            EXEC master.sys.sp_OAGetErrorInfo @ObjectToken, @ErrorSource OUTPUT, @ErrorDesc OUTPUT 
            RAISERROR('Create Error (return: ''%u'', source: ''%s'', description: ''%s'')', 15, 1, @ObjectReturn, @ErrorSource, @ErrorDesc)
       END

    /* Set the file to binary type */
    EXEC @ObjectReturn = master.sys.sp_OASetProperty @ObjectToken, 'Type', 1
    IF (@ObjectReturn <> 0)
        BEGIN
            EXEC master.sys.sp_OAGetErrorInfo @ObjectToken, @ErrorSource OUTPUT, @ErrorDesc OUTPUT 
            RAISERROR('Set bianry type Error (return: ''%u'', source: ''%s'', description: ''%s'')', 15, 1, @ObjectReturn, @ErrorSource, @ErrorDesc)
        END
	/*open the file*/
   EXEC @ObjectReturn = master.sys.sp_OAMethod @ObjectToken, 'Open'
    IF (@ObjectReturn <> 0)
        BEGIN
            EXEC master.sys.sp_OAGetErrorInfo @ObjectToken, @ErrorSource OUTPUT, @ErrorDesc OUTPUT 
            RAISERROR('Open Error (return: ''%u'', source: ''%s'', description: ''%s'')', 15, 1, @ObjectReturn, @ErrorSource, @ErrorDesc)
        END

    /* Write the file */
   EXEC @ObjectReturn = master.sys.sp_OAMethod @ObjectToken, 'Write', NULL, @IMG_PATH
    IF (@ObjectReturn <> 0)
        BEGIN
            EXEC master.sys.sp_OAGetErrorInfo @ObjectToken, @ErrorSource OUTPUT, @ErrorDesc OUTPUT 
            RAISERROR('Write Error (return: ''%u'', source: ''%s'', description: ''%s'')', 15, 1, @ObjectReturn, @ErrorSource, @ErrorDesc)
        END
        
   /* Save the file */
   EXEC @ObjectReturn = master.sys.sp_OAMethod @ObjectToken, 'SaveToFile', NULL,@fullPathName , 2
    IF (@ObjectReturn <> 0)
        BEGIN
            EXEC master.sys.sp_OAGetErrorInfo @ObjectToken, @ErrorSource OUTPUT, @ErrorDesc OUTPUT 
            RAISERROR('SaveToFile Error (return: ''%u'', source: ''%s'', description: ''%s'')', 15, 1, @ObjectReturn, @ErrorSource, @ErrorDesc)
       END
        
    /* Close the file. */
    EXEC @ObjectReturn = master.sys.sp_OAMethod @ObjectToken, 'Close'
    IF (@ObjectReturn <> 0)
        BEGIN
            EXEC master.sys.sp_OAGetErrorInfo @ObjectToken, @ErrorSource OUTPUT, @ErrorDesc OUTPUT 
            RAISERROR('Close Error (return: ''%u'', source: ''%s'', description: ''%s'')', 15, 1, @ObjectReturn, @ErrorSource, @ErrorDesc)
       END

    /* Destroy the text stream object. */
    EXEC @ObjectReturn = master.sys.sp_OADestroy @ObjectToken
    IF (@ObjectReturn <> 0)
        BEGIN
            EXEC master.sys.sp_OAGetErrorInfo @ObjectToken, @ErrorSource OUTPUT, @ErrorDesc OUTPUT 
            RAISERROR('Destroy Error (return: ''%u'', source: ''%s'', description: ''%s'')', 15, 1, @ObjectReturn, @ErrorSource, @ErrorDesc)
        END

END TRY
BEGIN CATCH
    SELECT
        @ErrorNumber = ERROR_NUMBER(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE(),
        @ErrorProcedure = ERROR_PROCEDURE(),
        @ErrorLine = ERROR_LINE(),
        @ErrorMessage = ERROR_MESSAGE();
    RAISERROR('Procedure ''%s'' failed on line number ''%u'' with message ''%s'' - (error number: ''%u'', severity: ''%u'', state: ''%u'').', 15, 1, @ErrorProcedure, @ErrorLine, @ErrorMessage, @ErrorNumber, @ErrorSeverity, @ErrorState)
	RETURN @ErrorNumber
END CATCH

RETURN 0
GO
