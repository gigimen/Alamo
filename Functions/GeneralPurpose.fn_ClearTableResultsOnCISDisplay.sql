SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [GeneralPurpose].[fn_ClearTableResultsOnCISDisplay](@tablename [NVARCHAR](4000))
RETURNS [NVARCHAR](4000) 
AS
BEGIN
	DECLARE @ip NVARCHAR(4000),@ret NVARCHAR(4000),@table NVARCHAR(4000),@port INT

	SELECT @ip = varValue FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerIpAddress'
	SELECT @port = CAST(varValue AS INT) FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerPortNumber'


	SET @table = REPLACE(@tablename,' ','')
	SELECT @ret = [GeneralPurpose].[asm_SendToCIS] (
	  'HOSTNAME="' + @table + '" EXC="CIS100" TABLENAME="' + @table + '" GAMETYPE="' + left(@table,2) +'" TYPE="NG"',
--	'A="B" TABLENAME="' + @table + '" EXC="CIS100" TYPE="NG"',
	  @ip,--'10.41.41.8'
	  @port--,1000
	  )
	RETURN @ret
END
GO
