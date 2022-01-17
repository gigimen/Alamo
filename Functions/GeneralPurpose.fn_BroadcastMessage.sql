SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION  [GeneralPurpose].[fn_BroadcastMessage] 
(
@type varchar(32),
@attribs varchar(1024)
)
RETURNS NVARCHAR(4000) 
WITH SCHEMABINDING
AS  
BEGIN

/*

declare
@type varchar(32),
@attribs varchar(1024)
set @type = 'xxx'

set  @attribs = 'c=''4'''
--*/
DECLARE @ret NVARCHAR(4000)

declare @payload varchar(4000)

if @type is null
begin
	SET @ret = 'Must specify the type of message'
	return @ret
end

IF @attribs is NULL OR LEN (@attribs) = 0
	set @payload = '<ALAMO version=''1''><MESS type=''' + @type + '''/></ALAMO>'
else
	set @payload = '<ALAMO version=''1''><MESS type=''' + @type + ''' ' + @attribs + '/></ALAMO>'

--adesso broadcastiamo sull rete EAKS VLAN241 172.18.18.0
SELECT 
		@ret = [GeneralPurpose].[asm_Broadcast] 
		(
		'{F3B79F92-3917-4a42-90EB-0F854EB683E7}' --alamo guid
		,1 --version number
		,'192.168.1.255'--172.18.18.255'-- ne.VarValue
		,'255.255.255.0'--ma.VarValue
		,CAST(po.VarValue as int)
		,@payload
		)
FROM 
[GeneralPurpose].[ConfigParams] po--,
--[GeneralPurpose].[ConfigParams] ne,
--[GeneralPurpose].[ConfigParams] ma		
WHERE po.VarName = 'AlamoMessagesPort'
--	and ne.VarName = 'AlamoMessagesNetwork'
--	and ma.VarName = 'AlamoMessagesMask'

RETURN @ret

END
GO
