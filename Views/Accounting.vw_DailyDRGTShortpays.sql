SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_DailyDRGTShortpays]
WITH SCHEMABINDING
AS
SELECT [SourceGamingDate] AS GamingDate
      ,SUM([Quantity] * Denomination) AS Amount
      ,SUM(CASE WHEN denoid = 64 then [Quantity] * Denomination ELSE [Quantity] * Denomination * r.IntRate END ) AS CHF
  FROM [Accounting].[vw_AllTransactionDenominations] s
  INNER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = s.SourceGamingDate
  WHERE SourceGamingDate >= '1.16.2019' AND denoid IN(165,64) 
  AND r.CurrencyID = 0
  GROUP BY  [SourceGamingDate]


GO
