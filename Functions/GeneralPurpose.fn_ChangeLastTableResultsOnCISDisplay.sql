SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [GeneralPurpose].[fn_ChangeLastTableResultsOnCISDisplay](@tablename [NVARCHAR](4000), @res int)
RETURNS [NVARCHAR](4000) 
AS
BEGIN
	DECLARE @ip NVARCHAR(4000),@ret NVARCHAR(4000),@table NVARCHAR(4000),@port INT

	SELECT @ip = varValue FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerIpAddress'
	SELECT @port = CAST(varValue AS INT) FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerPortNumber'

	SET @table = REPLACE(@tablename,' ','')
	SELECT @ret = [GeneralPurpose].[asm_SendToCIS] (
	  'HOSTNAME="' + @table + '" EXC="CIS100" SRC="'+ @table + '" DST="ALL" TABLENAME="' + @table + '" GAMETYPE="' + left(@table,2) +'" TYPE="MNC" NUMBER="'+ 
				--'36'
				cast(@res as varchar(8))
				+'"',
	  @ip,--'10.41.41.8'
	  @port--,1000
	  )
	RETURN @ret
END

GO
