SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [GeneralPurpose].[fn_CastDateForAdoRead] (@inVal datetime)  
RETURNS VARCHAR(32) 
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @outVal  VARCHAR(33)
	--in DATE definition is form 30-12-1899 and not 01-01-1900 as in datetime in sql-server
	--SET @outVal = CAST(CAST(@inVal as float) + 2 as varchar(32))
	SELECT @outVal = CONVERT(VARCHAR(33), @inVal, 126) 
	RETURN (@outVal)
END






GO
