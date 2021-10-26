SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_MovimentiDotazioneByCurrency]
AS

/*
SELECT [GamingDate]
      ,[ConteggioTimeLoc]
	  ,ConteggioID
      ,StockID
      ,StockTypeID
	  ,CurrencyAcronim
      ,SUM(Quantity * [Denomination]) AS  [TotaleGettoni]
FROM [Accounting].[vw_AllConteggiDenominations]
WHERE [SnapshotTypeID] = 17
GROUP BY [GamingDate]
      ,[ConteggioTimeLoc]
	  ,ConteggioID
      ,StockID
      ,StockTypeID
      ,CurrencyAcronim

	  */


SELECT SourceGamingDate AS [GamingDate]
      ,SourceTimeLoc
	  ,TransactionID
      ,SourceStockID
      ,SourceStockTypeID
	  ,CurrencyAcronim
      ,SUM((Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) * [Denomination]) AS [TotaleGettoni]
FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE OpTypeID = 18
GROUP BY SourceGamingDate 
      ,SourceTimeLoc
	  ,TransactionID
      ,SourceStockID
      ,SourceStockTypeID
	  ,CurrencyAcronim
GO
