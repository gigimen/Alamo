SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [GeneralPurpose].[usp_DOSGroup_ClubVerified] 
@cardid INT ,
@verified BIT,
@errorMsg VARCHAR(1024) OUTPUT
AS


	DECLARE @UserKey NVARCHAR(4000),@password NVARCHAR(4000),@token NVARCHAR(4000),@newtoken NVARCHAR(4000)

	SELECT @UserKey = VarValue FROM [GeneralPurpose].[ConfigParams] WHERE VarName = 'DOSGroup-Username'
	IF @UserKey IS NULL OR LEN(@UserKey) = 0
	BEGIN
		RAISERROR('Errore in lettura DOSGroup-Username in configurazione',16,1)
		RETURN(1)
	END

	SELECT @password = VarValue FROM [GeneralPurpose].[ConfigParams] WHERE VarName = 'DOSGroup-Password'
	IF @password IS NULL OR LEN(@password) = 0
	BEGIN
		RAISERROR('Errore in lettura SMSkdevPassword in configurazione',16,1)
		RETURN(1)
	END


	SELECT @token = VarValue FROM [GeneralPurpose].[ConfigParams] WHERE VarName = 'DOSGroup-Token'
	IF @token IS NULL 
		SET @token = ''


	DECLARE @xmlvalues NVARCHAR(4000)
/*	SET @xmlvalues ='<OParam><ErrorCode>9</ErrorCode><ErrorMessage>ClubCode Not Found</ErrorMessage><Token/><Points/></OParam>'
	DECLARE @XML xml = @xmlvalues
	SELECT	
		T.N.value('(ErrorCode/text())[1]', 'int'),
		T.N.value('(Token/text())[1]', 'varchar(4000)'),
		T.N.value('(ErrorMessage/text())[1]', 'varchar(1024)'),
		T.N.value('(Points/text())[1]', 'int')
	from @XML.nodes('OParam') as T(N)	
*/
	SELECT @xmlvalues = [SQLWebAPI].[asm_DOSGroup_ClubVerified] (
	   @UserKey
	  ,@password
	  ,@token
	  ,@cardid
	  ,@verified)
	  
	--<OParam><ErrorCode>0</ErrorCode><ErrorMessage>OK</ErrorMessage><Token>8981d14af91390afed2d8975134855f4</Token><Points>14</Points></OParam>
	--loggami la risposta
	INSERT INTO [SQLWebAPI].[tbl_DOSGroupAPILogger] ([CardId],[API],[RetCodeDescription]) 
	VALUES (@cardid,'ClubVerified',@xmlvalues)



	DECLARE @XML XML = @xmlvalues,@errorCode int
	SELECT	
		@errorCode	= T.N.value('(ErrorCode/text())[1]', 'int'),
		@newtoken	= T.N.value('(Token/text())[1]', 'varchar(4000)'),
		@errorMsg	= T.N.value('(ErrorMessage/text())[1]', 'varchar(1024)')
	FROM @XML.nodes('OParam') AS T(N)	

	IF @token <> @newtoken
		UPDATE [GeneralPurpose].[ConfigParams] SET VarValue = @newtoken	WHERE VarName = 'DOSGroup-Token'
	
	RETURN @errorCode	


GO
