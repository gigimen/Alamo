SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_DailyTavoliTotRipristinato]
WITH SCHEMABINDING
AS
SELECT COUNT([StockID]) AS tavoli
		,GamingDate
		--,StocktypeName
      ,SUM([Consegna]) AS totConsegnato
      ,SUM([Ripristino]) AS totRipristino
      ,SUM([Ripristino]) - SUM([Consegna])  AS totRipristinato
  FROM [Accounting].[vw_AllConsegnaRipristiniTavoli]
  GROUP BY GamingDate--,StocktypeName
GO
