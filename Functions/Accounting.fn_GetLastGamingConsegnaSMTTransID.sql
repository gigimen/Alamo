SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Accounting].[fn_GetLastGamingConsegnaSMTTransID] ()  
RETURNS INT 
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @outVal INT, @gamingdate DATETIME

	--consegna from SMT the same day of current GM of MS
	SELECT   @gamingdate = GeneralPurpose.fn_GetGamingLocalDate2(GETDATE(),0,2) --SMT

	SELECT @outVal = Accounting.fn_GetConsegnaSMTTransID(@gamingdate)

	RETURN @outVal
END





GO
