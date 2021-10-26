SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [SQLWebAPI].[usp_SendSMS] 
@recipeints	NVARCHAR(MAX),
@sms		NVARCHAR(1024),
@o			NVARCHAR(MAX) OUTPUT
AS
--
IF @recipeints IS NULL OR LEN(@recipeints) = 0
BEGIN
	RAISERROR('Must specify the recipeints',16,1)
	RETURN(1)
END

IF @sms IS NULL OR LEN(@sms) = 0
BEGIN
	RAISERROR('Must specify the sms text',16,1)
	RETURN(1)
END

DECLARE @UserKey NVARCHAR(4000),@password NVARCHAR(4000),@url NVARCHAR(4000)

SELECT @url = VarValue FROM [GeneralPurpose].[ConfigParams] WHERE VarName = 'SMSkdevURL'
IF @url IS NULL OR LEN(@url) = 0
BEGIN
	RAISERROR('Errore in lettura SMSurl in configurazione',16,1)
	RETURN(1)
END


SELECT @UserKey = VarValue FROM [GeneralPurpose].[ConfigParams] WHERE VarName = 'SMSkdevUserKey'
IF @UserKey IS NULL OR LEN(@UserKey) = 0
BEGIN
	RAISERROR('Errore in lettura SMSkdevUserKey in configurazione',16,1)
	RETURN(1)
END

SELECT @password = VarValue FROM [GeneralPurpose].[ConfigParams] WHERE VarName = 'SMSkdevPassword'
IF @password IS NULL OR LEN(@password) = 0
BEGIN
	RAISERROR('Errore in lettura SMSkdevPassword in configurazione',16,1)
	RETURN(1)
END

BEGIN TRY

	SELECT @o = SQLWebAPI.[asm_SqlSMSkdev_SendSMS](
		@url,
		@UserKey,
		@password,
		@recipeints ,
		@sms)
END TRY
BEGIN CATCH

	SET @o = LEFT(ERROR_MESSAGE(),256)

END CATCH

DECLARE @err int
BEGIN TRANSACTION InsertSentSMS
INSERT INTO SQLWebAPI.[tbl_SentSMSMessages]
	([recipients]
	,[messageText]
	,[answer]
	)
VALUES
	(@recipeints
	,@sms
	,@o)
SELECT @err = @@ERROR IF (@ERR <> 0) BEGIN ROLLBACK TRANSACTION InsertSentSMS return @ERR END

COMMIT TRANSACTION InsertSentSMS

RETURN 0

GO
