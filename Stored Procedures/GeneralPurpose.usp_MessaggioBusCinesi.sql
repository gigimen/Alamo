SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GeneralPurpose].[usp_MessaggioBusCinesi]
AS


declare @messageEnabled						int

SELECT @messageEnabled = cast ([VarValue] as int)
FROM [GeneralPurpose].[ConfigParams]
where [VarName] = 'BusCinesiEnabled' and VarType = 3

if @messageEnabled <> 0
begin

	EXEC	[GeneralPurpose].[usp_BroadcastMessage]
			@type = N'wav',
			@attribs = N'filename=''bus-cinesi.wav'''
	
	print 'Message for bus cinesi sent'
end
else 
	print 'Message for bus cinesi disabled'

GO
