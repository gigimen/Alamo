SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Managers].[msp_TestCMDShell]
@cmd VARCHAR(1924)
AS
/*

execute [Managers].[msp_TestCMDShell] 'd:\ConsoleREST.exe'

*/
DECLARE @token varchar(4000),@newtoken varchar(4000)

select @token = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'TokenDOSRESTAPI'
if @token is null
BEGIN

	INSERT INTO [GeneralPurpose].[ConfigParams]
           ([VarName]
           ,[VarType]
           ,[VarValue])
     VALUES
           ('TokenDOSRESTAPI'
           ,8
           ,'')
	SET @token = ''
end

IF LEN(@token ) > 0
	SET @cmd += ' ' + @token


DECLARE @o AS TABLE(ans VARCHAR(4000))
INSERT INTO @o 
EXEC sys.xp_cmdshell @cmd;  

--SELECT * WHERE ans LIKE 'Token%'

SELECT @newtoken = RIGHT(ans,LEN(ans) - CHARINDEX(':',ans,0) - 1) 
FROM @o
WHERE ans LIKE 'Token%'

IF @newtoken is null 
	SET @newtoken = ''

IF @newtoken <> @token
	UPDATE [GeneralPurpose].[ConfigParams] 
		SET VarValue = @newtoken
	WHERE VarName = 'TokenDOSRESTAPI'

IF @newtoken = ''
	SELECT * FROM @o

GO
