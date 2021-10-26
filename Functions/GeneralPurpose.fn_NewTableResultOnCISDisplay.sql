SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [GeneralPurpose].[fn_NewTableResultOnCISDisplay] (@tablename [NVARCHAR](4000),@res int)
RETURNS [NVARCHAR](4000) 
AS
BEGIN


	DECLARE @ip NVARCHAR(4000),@ret NVARCHAR(4000),@table NVARCHAR(4000),@port INT

	SELECT @ip = varValue FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerIpAddress'
	SELECT @port = CAST(varValue AS INT) FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerPortNumber'

	if (@res is null or @res < 0 or @res > 36) 
	begin
		--raiserror('Invalid spin number %d specified',16,-1,@res)
		set @ret = 'Invalid spin number specified'
	end
	else
	begin
		SET @table = REPLACE(@tablename,' ','')

		declare @cmd nvarchar(4000)
		if left(@table,2) ='AR'	
			SET @cmd = 
				N'HOSTNAME="' + @table + '" EXC="CIS100" TABLENAME="' + @table + '" GAMETYPE="' + left(@table,2) +'" TYPE="WN" SUBTYPE="GAMERESULT" NUMBER="'+ 
				--'36'
				cast(@res as varchar(8))
				+'" DIRECTION="1" WHEELSPEED="11" LASTNUMBERS=""'
		else if left(@table,2) ='PB'
			SET @cmd = 
				N'HOSTNAME="' + @table + '" EXC="CIS100" TABLENAME="' + @table + '" GAMETYPE="' + left(@table,2) +'" TYPE="WN" SUBTYPE="GAMERESULT" NUMBER="'+ 
				--'36'
				cast(@res as varchar(8))
				+'"'
		else if left(@table,2) ='BJ'
			SET @cmd = 
				N'HOSTNAME="' + @table + '" EXC="CIS100" TABLENAME="' + @table + '" GAMETYPE="' + left(@table,2) +'" TYPE="MN" SUBTYPE="GAMERESULT"' +
				' PLAYER="' + cast(@res as varchar(8)) +'" DEALER="' + cast(@res as varchar(8)) +'" NUMBER="' + cast(@res as varchar(8)) +'"'

		if len(@cmd) > 0
				SELECT @ret = [GeneralPurpose].[asm_SendToCIS] (
					@cmd,
					@ip,--'10.41.41.8'
					@port--,1000
				) 

  	end
	RETURN @ret
END

GO
