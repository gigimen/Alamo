SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_CashChiusureCasse]
AS
SELECT 
chf.Casse		AS CassAperte
,chf.GamingDate
,chf.Apertura  AS AperturaCHF
,chf.Chiusura  AS ChiusuraCHF
,chf.Consegna	AS ConsegnaCHF
,chf.Ripristino  AS RipristinoCHF
,eur.Apertura  AS AperturaEUR
,eur.Chiusura  AS ChiusuraEUR
,eur.Consegna  AS ConsegnaEUR
,eur.Ripristino  AS RipristinoEUR
,eur.euroRate
,chf.Apertura - (chf.Chiusura - chf.Consegna + chf.Ripristino) AS CHFCheck
,eur.Apertura - (eur.Chiusura - eur.Consegna + eur.Ripristino) AS EURCheck

FROM
(
	SELECT COUNT(DISTINCT [StockID]) AS casse
		  ,c.[GamingDate]
		  --,[ValueTypeID]
		  --,[ValueTypeName]
		  --,[CurrencyID]
		  ,SUM([Denomination] * c.InitialQty ) AS Apertura
		  ,SUM([Denomination] * Chiusura ) AS Chiusura
		  ,SUM([Denomination] * Consegna ) AS Consegna
		  ,SUM([Denomination] * Ripristino) AS Ripristino
	FROM [Accounting].[vw_AllChiusuraConsegnaDenominations] c
	WHERE ValueTypeID IN(2,3) AND c.StockTypeID IN(4,7) AND c.CurrencyID = 4
	GROUP BY c.[GamingDate]
		  --,[ValueTypeID]
		  --,[ValueTypeName]
		  --,[CurrencyID]
) chf 
FULL OUTER join
(
	SELECT COUNT(DISTINCT [StockID]) AS casse
		  ,c.[GamingDate]
		  --,[ValueTypeID]
		  --,[ValueTypeName]
		  --,[CurrencyID]
		  ,r.IntRate AS euroRate
		  ,SUM([Denomination] * c.InitialQty ) AS Apertura
		  ,SUM([Denomination] * Chiusura ) AS Chiusura
		  ,SUM([Denomination] * Consegna ) AS Consegna
		  ,SUM([Denomination] * Ripristino) AS Ripristino
	FROM [Accounting].[vw_AllChiusuraConsegnaDenominations] c
	INNER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = c.GamingDate AND r.CurrencyID = c.CurrencyID
	WHERE ValueTypeID IN(7) AND c.StockTypeID IN(4,7) AND c.CurrencyID = 0
	GROUP BY c.[GamingDate]
		  --,[ValueTypeID]
		  --,[ValueTypeName]
		  --,[CurrencyID]
		  ,r.IntRate
) eur ON eur.gamingdate = chf.GamingDate
GO
