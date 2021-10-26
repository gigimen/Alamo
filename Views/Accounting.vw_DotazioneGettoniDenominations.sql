SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Accounting].[vw_DotazioneGettoniDenominations]
AS
/*
SELECT ValueTypeName
	  ,ValueTypeID
	  ,DenoID
	  ,CurrencyAcronim
	  ,CurrencyID
	  ,DenoName
	  ,Denomination
	  ,SUM(Quantity) AS Totale
FROM [Accounting].[vw_AllConteggiDenominations]
WHERE [SnapshotTypeID] = 17 --AND GamingDate <= '6.1.2019'
GROUP BY ValueTypeName
	  ,ValueTypeID
	  ,DenoID
	  ,CurrencyAcronim
	  ,CurrencyID
	  ,DenoName
	  ,Denomination

*/

SELECT ValueTypeName
	  ,ValueTypeID
	  ,DenoID
	  ,CurrencyAcronim
	  ,CurrencyID
	  ,FDescription AS DenoName
	  ,Denomination
	  ,SUM((Quantity) * CASE WHEN CashInbound = 1 THEN 1 ELSE -1 end) AS Totale
FROM [Accounting].[vw_AllTransactionDenominations]
WHERE OpTypeID = 18 --AND GamingDate <= '6.1.2019'
GROUP BY ValueTypeName
	  ,ValueTypeID
	  ,DenoID
	  ,CurrencyAcronim
	  ,CurrencyID
	  ,FDescription
	  ,Denomination	
	

GO
