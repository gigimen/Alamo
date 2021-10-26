SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_DotazioneGettoni]
AS
/*
SELECT ValueTypeName
	  ,ValueTypeID
	  ,CurrencyAcronim
	  ,CurrencyID
      ,SUM(Quantity * [Denomination]) AS [Totale]
FROM [Accounting].[vw_AllConteggiDenominations]
WHERE [SnapshotTypeID] = 17
GROUP BY ValueTypeName
	  ,ValueTypeID
	  ,CurrencyAcronim
	  ,CurrencyID

*/
	


SELECT ValueTypeName
	  ,ValueTypeID
	  ,CurrencyAcronim
	  ,CurrencyID
	  ,SUM((Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END) * [Denomination]) AS Totale
FROM [Accounting].[vw_AllTransactionDenominations]
WHERE OpTypeID = 18
GROUP BY ValueTypeName
	  ,ValueTypeID
	  ,CurrencyAcronim
	  ,CurrencyID

	
	


GO
