SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[msp_AddDosPoints]
@cardid INT,
@points INT output
AS

IF @cardid IS NULL OR NOT EXISTS (
SELECT GoldenClubCardId FROM GoldenClub.tbl_Members WHERE GoldenClubCardID = @cardid AND CancelID IS null
)
BEGIN
	raiserror('Invalid CardID (%d) specified',16,1,@cardid)
	RETURN (1)
END


/*

declare @cardid int

set @cardid = 100299

--*/
DECLARE @exefullpath VARCHAR(1024),@IParams VARCHAR(1024)
SET  @exefullpath = 'd:\ConsoleRest.exe '



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
END

/*
esempio di formattazione dei parametri di ingresso

<IParams><token>a32a542ec5f22d3a8953e56869142990</token><cardid>345656</cardid></IParams>


*/

IF LEN(@token) > 0
	SELECT @IParams = '<IParams><token>' + @token + '</token><cardid>' + CAST(@cardid AS VARCHAR(32)) + '</cardid></IParams>'
ELSE
	SELECT @IParams = '<IParams><token /><cardid>' + CAST(@cardid AS VARCHAR(32)) + '</cardid></IParams>'


select @exefullpath += '"' + @IParams + '"';  

BEGIN TRY  

	DECLARE @o AS TABLE(ans VARCHAR(4000))
	INSERT INTO @o 
	EXEC sys.xp_cmdshell @exefullpath;  

	--select ans from @o


	/*
	esempio di risposta
	<?xml version="1.0" encoding="utf-16"?>
<OParams xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <token>a32a542ec5f22d3a8953e56869142990</token>
  <errorcode>0</errorcode>
  <errordescr />
  <points>8</points>
</OParams>
	
	*/
	DECLARE @row varchar(4000),@xmlvalues nvarchar(max),@errordescr nvarchar(1024),@errorcode INT
	DECLARE cur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR select ans from @o
	OPEN cur

	FETCH NEXT FROM cur INTO @row 
	set @xmlvalues = ''
	WHILE @@FETCH_STATUS = 0
	BEGIN

		if @row is not null
			set @xmlvalues = @xmlvalues + @row
		FETCH NEXT FROM cur INTO @row 

	END

	CLOSE cur
	DEALLOCATE cur

	SELECT @xmlvalues


	/*
	
	DECLARE @xmlvalues nvarchar(max),@newtoken varchar(4000),@errordescr nvarchar(1024),@errorcode INT,@points int
	set @xmlvalues = '<?xml version="1.0" encoding="utf-16"?><OParams xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><token>a32a542ec5f22d3a8953e56869142990</token><errorcode>0</errorcode><errordescr /><points>8</points></OParams>'	

	DECLARE @XML xml = @xmlvalues
	SELECT 
		T.N.value('(token/text())[1]', 'varchar(4000)'),
		T.N.value('(errorcode/text())[1]', 'int'),
		T.N.value('(errordescr/text())[1]', 'varchar(1024)'),
		T.N.value('(points/text())[1]', 'int')
	from @XML.nodes('OParams') as T(N)	


	--*/

	DECLARE @XML XML = @xmlvalues

	SELECT 
		@newtoken = T.N.value('(token/text())[1]', 'varchar(4000)'),
		@errorcode = T.N.value('(errorcode/text())[1]', 'int'),
		@errordescr = T.N.value('(errordescr/text())[1]', 'varchar(1024)'),
		@points = T.N.value('(points/text())[1]', 'int')
	FROM @XML.nodes('OParams') AS T(N)

	IF @errorcode <> 0 AND LEN(@errordescr) > 0
	BEGIN
		RAISERROR('ERROR in REST API(%d): %s',16,1,@errorcode,@errordescr )
		RETURN (1)
	END

	IF @newtoken IS NULL 
		SET @newtoken = ''

	IF @newtoken <> @token
		UPDATE [GeneralPurpose].[ConfigParams] 
			SET VarValue = @newtoken
		WHERE VarName = 'TokenDOSRESTAPI'

END TRY  
BEGIN CATCH  
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN 0

GO
