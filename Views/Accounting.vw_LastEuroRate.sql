SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Accounting].[vw_LastEuroRate]
WITH SCHEMABINDING
AS
SELECT  
	GamingDate, 
	IntRate
FROM  Accounting.tbl_CurrencyGamingdateRates  
WHERE Gamingdate = (SELECT MAX(gamingdate) FROM  Accounting.tbl_CurrencyGamingdateRates WHERE CurrencyID = 0)
AND CurrencyID = 0









GO
