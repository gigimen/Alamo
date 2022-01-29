SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [GeneralPurpose].[fn_ChangeMinBetOnCISDisplay] (@tablename [NVARCHAR](4000),@minbet INT)
RETURNS [NVARCHAR](4000) 
AS
BEGIN


	DECLARE @ip NVARCHAR(4000),@ret NVARCHAR(4000),@table NVARCHAR(4000),@port INT

	SELECT @ip = varValue FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerIpAddress'
	SELECT @port = CAST(varValue AS INT) FROM GeneralPurpose.ConfigParams WHERE VarName = 'CISServerPortNumber'

/*IF (@minbet IS NULL OR @minbet NOT IN (10,20) ) 
	BEGIN
		--raiserror('Invalid spin number %d specified',16,-1,@res)
		SET @ret = 'Invalid @minbet specified'
	END
	ELSE
	BEGIN
*/		SET @table = REPLACE(@tablename,' ','')

		DECLARE @cmd NVARCHAR(4000)
		IF LEFT(@table,2) ='AR'	
			SET @cmd = 
				N'HOSTNAME="' + @table + '" EXC="CIS100" TABLENAME="' + @table + '" GAMETYPE="' + LEFT(@table,2) +'" TYPE="MINBET" SUBTYPE="GAMERESULT" NUMBER="'+ 
				--'36'
				CAST(@minbet AS VARCHAR(8))
				+'" DIRECTION="1" WHEELSPEED="11" LASTNUMBERS=""'
		ELSE IF LEFT(@table,2) ='PB'
			SET @cmd = 
				N'HOSTNAME="' + @table + '" EXC="CIS100" TABLENAME="' + @table + '" GAMETYPE="' + LEFT(@table,2) +'" TYPE="MINBET" SUBTYPE="GAMERESULT" NUMBER="'+ 
				--'36'
				CAST(@minbet AS VARCHAR(8))
				+'"'
		ELSE IF LEFT(@table,2) ='BJ'
			SET @cmd = 
				N'HOSTNAME="' + @table + '" EXC="CIS100" TABLENAME="' + @table + '" GAMETYPE="' + LEFT(@table,2) +'" TYPE="MINBET" SUBTYPE="GAMERESULT"' +
				' PLAYER="' + CAST(@minbet AS VARCHAR(8)) +'" DEALER="' + CAST(@minbet AS VARCHAR(8)) +'" NUMBER="' + CAST(@minbet AS VARCHAR(8)) +'"'

		IF LEN(@cmd) > 0
				SELECT @ret = [GeneralPurpose].[asm_SendToCIS] (
					@cmd,
					@ip,--'10.41.41.8'
					@port--,1000
				) 

--  	END
	RETURN @ret
END

GO
