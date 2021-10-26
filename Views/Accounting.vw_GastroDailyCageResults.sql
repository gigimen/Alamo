SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_GastroDailyCageResults]
AS
SELECT c.[GamingDate]
      ,c.[StockID]
      ,c.[Tag]
      ,c.[Totale]										AS Conteggio
	  ,f.TotaleCHF										AS FondoCassa
	  ,ISNULL(g.[Cash],0)								AS TCPOSCash
	  ,ISNULL(g.[Cash],0) + ISNULL(g.[CarteDiCredito],0) + ISNULL(g.[Buoni],0) + ISNULL(g.[Debitori],0) + ISNULL(g.[Altro],0) AS IncassoTCPOS
      ,c.[Totale]  - f.TotaleCHF						AS Incasso
      ,c.[Totale]  - f.TotaleCHF - ISNULL(g.[Cash],0)	AS Mance
	  
FROM [Accounting].[vw_GastroDailyConteggio] c
INNER JOIN [CasinoLayout].[vw_AllStockCompositionTotalsEx] f ON f.StockID = c.StockID AND f.EndOfUseGamingDate IS NULL
LEFT OUTER JOIN [Accounting].[vw_GastroDailyTCPOSCash] g ON g.StockID = c.StockID AND g.GamingDate = c.GamingDate
GO
