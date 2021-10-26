SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_DailyEuroTransaction]
AS
/*
SELECT
ISNULL(a.LifeCycleID,b.LifeCycleID) AS LifeCycleID,
ISNULL(a.EURToCHF,0) + ISNULL(b.EURToGettoni,0) AS EURToCHF,
ISNULL(a.CHFToEUR,0) + ISNULL(b.GettoniToEUR,0) AS CHFToEUR,
ISNULL(a.UtileCambio,0) AS UtileCambio 
FROM 
(*/
	SELECT [LifeCycleID]
	--euro convertiti a franchi: redeem +vendite -acq € + redem - acq gettoni gioco euro
      ,CAST(
		SUM(
			CASE WHEN OpTypeID = 11 --only cambios 
			THEN -[ImportoEuroCents] 
			ELSE [ImportoEuroCents] END 
			) AS FLOAT
			) / 100.0 AS EURToCHF
      ,SUM(
		CASE WHEN OpTypeID = 11 --only cambios
		THEN [CHFEquiv] 
		ELSE -[CHFEquiv] END 
		) AS CHFToEUR
		,SUM(UtileCambio) AS UtileCambio
  FROM [Accounting].[vw_AllEuroTransactions]
  GROUP BY LifeCycleID
/*) a
FULL outer JOIN 
(
	SELECT [LifeCycleID]
      ,SUM(CASE WHEN [DenoID] = 182 THEN -[TotEuro] ELSE [TotEuro] END ) AS EURToGettoni
      ,SUM(CASE WHEN [DenoID] = 182 THEN [TotGettoni] ELSE -[TotGettoni] END ) AS GettoniToEUR
	FROM [Accounting].[vw_AllMovimentiGettoniGiocoEuro]
	GROUP BY LifeCycleID
)b ON b.LifeCycleID = a.LifeCycleID


*/
GO
