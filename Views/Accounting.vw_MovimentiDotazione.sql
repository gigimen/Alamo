SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_MovimentiDotazione]
AS
/*
SELECT [GamingDate]
      ,[ConteggioTimeLoc]
	  ,ConteggioID
      ,StockID
      ,StockTypeID
      ,SUM(CASE WHEN ValueTypeID = 36 THEN Quantity * [Denomination] ELSE 0 END) AS [Totale Gettoni gioco EUR]
      ,SUM(CASE WHEN ValueTypeID = 1 THEN Quantity * [Denomination] ELSE 0 END) AS  [Totale Gettoni gioco CHF]
      ,SUM(CASE WHEN ValueTypeID = 42 THEN Quantity * [Denomination] ELSE 0 END) AS  [Totale Gettoni EUR]
FROM [Accounting].[vw_AllConteggiDenominations]
WHERE [SnapshotTypeID] = 17
GROUP BY [GamingDate]
      ,StockID
      ,StockTypeID
      ,[ConteggioTimeLoc]
      ,ConteggioID


*/
SELECT SourceGamingDate AS [GamingDate]
      ,SourceTimeLoc
	  ,TransactionID
      ,SourceStockID
      ,SourceStockTypeID
      ,SUM(CASE WHEN ValueTypeID = 36	THEN (Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) * [Denomination] ELSE 0 END) AS [Totale Gettoni gioco EUR]
      ,SUM(CASE WHEN ValueTypeID = 1	THEN (Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) * [Denomination] ELSE 0 END) AS [Totale Gettoni gioco CHF]
      ,SUM(CASE WHEN ValueTypeID = 42	THEN (Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) * [Denomination] ELSE 0 END) AS [Totale Gettoni EUR]
FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE OpTypeID = 18
GROUP BY SourceGamingDate 
      ,SourceTimeLoc
	  ,TransactionID
      ,SourceStockID
      ,SourceStockTypeID
GO
