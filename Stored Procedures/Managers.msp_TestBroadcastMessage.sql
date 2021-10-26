SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [Managers].[msp_TestBroadcastMessage] 
AS

declare @type varchar(32),
@attribs varchar(1024)

set		@type = N'TestMessage'
set		@attribs = N'a=''1'' from=''alamo gosth'''

declare @port int
declare @network varchar(32)
declare @mask varchar(32)
declare @payload varchar(1296)


SELECT @attribs = N'a=''1'' from=''alamo ghost'' size=''' + CAST(size * 8/1024 AS VARCHAR(32)) + ' (MB)'' timestamp=''' + GeneralPurpose.fn_CastDateForAdoRead(GETDATE()) + ''''
FROM sys.master_files
WHERE DB_NAME(database_id) = 'Alamo' AND name = N'Alamo_Data';

--PRINT @attribs
if @type is null
begin
	raiserror('Must specify the type of message',16,1)
	return(1)
end

if @attribs is null
	set @payload = '<ALAMO version=''1''><MESS type=''' + @type + '''/></ALAMO>'
else
	set @payload = '<ALAMO version=''1''><MESS type=''' + @type + ''' ' + @attribs + '/></ALAMO>'



select @port = cast(VarValue as int) from [GeneralPurpose].[ConfigParams] where VarName = 'AlamoMessagesPort'
if @port is null
begin
	raiserror('Errore in lettura numero porta di comunicazione',16,1)
	return(1)
end
/*
select @network = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'AlamoMessagesNetwork'
if @network is null
begin
	raiserror('Errore in lettura rete di comunicazione',16,1)
	return(1)
end
select @mask = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'AlamoMessagesMask'
if @mask is null
begin
	raiserror('Errore in lettura maschera rete di comunicazione',16,1)
	return(1)
END
*/

SET @network = '172.18.18.255'-- ne.VarValue
set @mask = '255.255.255.0'--ma.VarValue

/*the old way with extended stored procedure
exec master.dbo.xp_AlamoBroadcast @port,@network,@payload,0
*/

DECLARE @ret NVARCHAR(4000)
SELECT @ret = [GeneralPurpose].[asm_Broadcast] (
	'{F3B79F92-3917-4a42-90EB-0F854EB683E7}' --alamo guid
	--'{28884f5e-a36a-4e6b-aa10-79ae40b8b1a9}' --excalibur guid
	,1 --version number
	,@network
	,@mask
	,@port
	,@payload)

PRINT @ret + @network + ':' + CAST (@port AS VARCHAR(32))



IF SUBSTRING(@ret,1,2) <> 'OK'
BEGIN
	RAISERROR(@ret,16,1)
	RETURN (1)
END

RETURN 0
GO
