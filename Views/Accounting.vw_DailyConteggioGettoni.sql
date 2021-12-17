SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_DailyConteggioGettoni]
WITH SCHEMABINDING
AS
/*

select * from [Accounting].[vw_DailyConteggioGettoni]
where GamingDate = '7.14.2019'
*/
SELECT 
	GamingDate,
	CurrencyID,
	CASE WHEN ValueTypeID = 59 THEN 'POK' ELSE CurrencyAcronim END AS CurrencyAcronim,
	SUM(TotQuantity) AS TotQuantity
  FROM [Accounting].[vw_DailyConteggi]
 WHERE ValueTypeID IN (1,36,42,59) --solo gettoni chf,gioco euro, eur e poker
  GROUP BY  GamingDate,
	CurrencyID,
	CASE WHEN ValueTypeID = 59 THEN 'POK' ELSE CurrencyAcronim END
GO
