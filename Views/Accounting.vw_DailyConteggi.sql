SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_DailyConteggi]
WITH SCHEMABINDING
AS
/*

*/
SELECT 
	GamingDate,
	TipoConteggio,
	SnapshotTypeID,
	CurrencyID,
	CurrencyAcronim,
	ValueTypeID,
	ValueTypeName,
	COUNT(DISTINCT StockID) AS Stocks,
	SUM(Quantity*Denomination) AS TotQuantity
  FROM [Accounting].[vw_AllConteggiDenominations]
 WHERE SnapshotTypeID NOT IN (14,15,24,25) --ignore sorveglianza conteggi
  --AND GamingDate = '7.14.2019'
  GROUP BY  GamingDate,
	TipoConteggio,
	SnapshotTypeID,
	CurrencyID,
	CurrencyAcronim,
	ValueTypeID,
	ValueTypeName
GO
