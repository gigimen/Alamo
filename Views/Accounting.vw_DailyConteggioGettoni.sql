SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
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
	CurrencyAcronim,
	SUM(TotQuantity) AS TotQuantity
  FROM [Accounting].[vw_DailyConteggi]
 WHERE ValueTypeID IN (1,36,42)
  GROUP BY  GamingDate,
	CurrencyID,
	CurrencyAcronim
GO
