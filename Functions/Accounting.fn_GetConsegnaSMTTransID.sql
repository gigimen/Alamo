SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Accounting].[fn_GetConsegnaSMTTransID] ( @gamingdate DATETIME)  
RETURNS INT 
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @outVal INT

	--last consegna from SMT
	SELECT  @outVal		= cct.CONTransactionID
	FROM [Accounting].[vw_AllChiusuraConsegnaRipristino] cct
	WHERE cct.GamingDate = @gamingdate
	AND cct.StockID  = 30 --source stock SMT	
	RETURN @outVal
END





GO
