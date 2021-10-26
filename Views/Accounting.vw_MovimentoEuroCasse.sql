SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Accounting].[vw_MovimentoEuroCasse]
AS
SELECT 
		ap.LifeCycleID,
		ap.StockID,
		ap.StockTypeID,
		ap.tag,
		ap.GamingDate,
		ISNULL(ap.TotAPERTURA,0)		AS Apertura,
		ISNULL(con.TotConsegna,0)		AS Consegna,
		ISNULL(chi.TotCHIUSURA,0)		AS Neltrolley,
		ISNULL(con.TotConsegna,0) + ISNULL(chi.TotCHIUSURA,0) AS Chiusura/*,
		ISNULL(ver.TotalVersamenti,0)	AS VersamentiAme,
		ISNULL(acc.Totacconti,0)		AS AccontiAMe,
		ISNULL(verAltri.TotalVersamenti,0)	AS VersamentiAdAltri,
		ISNULL(accAltri.Totacconti,0)		AS AccontiAdAltri*/
FROM 
(
	SELECT [LifeCycleID],gamingdate,StockID,StockTypeID,tag
		  ,SUM([InitialQty]*[Denomination]) AS TotAPERTURA
	FROM [Accounting].[vw_AllLifeCycleDenominations]
	WHERE StockTypeID IN (4,7) AND ValueTypeID = 7
	GROUP BY [LifeCycleID],gamingdate,StockID,StockTypeID,tag
) ap
FULL OUTER JOIN
(
	SELECT [SourceLifeCycleID]
		  ,SUM([Quantity]*[Denomination]) AS TotConsegna
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 6 AND SourceStockTypeID IN (4,7) AND ValueTypeID = 7
	GROUP BY [SourceLifeCycleID]
) con ON con.SourceLifeCycleID = ap.LifeCycleID
FULL OUTER JOIN
(
	SELECT [LifeCycleID]
		  ,SUM([Quantity]*[Denomination]) AS TotCHIUSURA
	FROM [Accounting].[vw_AllSnapshotDenominations] 
	WHERE SnapshotTypeID = 3 AND StockTypeID IN (4,7) AND ValueTypeID = 7
	GROUP BY [LifeCycleID]
) chi ON chi.LifeCycleID = con.SourceLifeCycleID
/*
FULL OUTER	JOIN 
(
	SELECT SourceLifeCycleID AS LifeCycleID,
	SUM([Quantity]*[Denomination]) AS TotAcconti
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 1 --accont
	AND ValueTypeID = 7
	GROUP BY SourceLifeCycleID
) acc ON acc.LifeCycleID = ap.LifeCycleID
FULL OUTER	JOIN  
(
	SELECT SourceLifeCycleID AS LifeCycleID,
	SUM([Quantity]*[Denomination]) AS TotalVersamenti
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 4 --versamento
	AND ValueTypeID = 7
	GROUP BY SourceLifeCycleID
)ver ON ver.LifeCycleID = ap.LifeCycleID
FULL OUTER	JOIN 
(
	SELECT DestLifeCycleID AS LifeCycleID,
	SUM([Quantity]*[Denomination]) AS TotAcconti
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 1 --accont
	AND ValueTypeID = 7
	GROUP BY DestLifeCycleID
) accAltri ON accAltri.LifeCycleID = ap.LifeCycleID
FULL OUTER	JOIN  
(
	SELECT DestLifeCycleID AS LifeCycleID,
	SUM([Quantity]*[Denomination]) AS TotalVersamenti
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 4 --versamento
	AND ValueTypeID = 7
	GROUP BY DestLifeCycleID
)verAltri ON verAltri.LifeCycleID = ap.LifeCycleID

*/



GO
