SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Accounting].[vw_EuroRunningStock]
WITH SCHEMABINDING
AS
--first get euro present in ripristino
--sum up ripristino and acconto
SELECT 
lf.LifeCycleID,
lf.Tag,
lf.StockID,
lf.GamingDate,
lf.CloseSnapshotID,
rip.RIP,
recv.Recv,
recv2.Recv2,
given.given,
given2.given2,
acq.AcquistiEuro,
acq.CountAcquisti,
rede.RedemptionsEuro,
rede.RedemptionCount,
ven.VenditeEuro,
ven.VenditeCount,
ven.UtileCambio,
ISNULL(rip.RIP,0) + 
ISNULL(recv.Recv,0) + 
ISNULL(recv2.Recv2,0) - 
(
ISNULL(given.given,0) + 
ISNULL(given2.given2,0)
) + 
ISNULL(acq.AcquistiEuro,0) - 
(
ISNULL(rede.RedemptionsEuro,0) + 
ISNULL(ven.VenditeEuro,0)
) AS CurrStockEuro
FROM Accounting.vw_AllStockLifeCycles lf
LEFT OUTER JOIN
(
SELECT 
	ISNULL(SUM(Quantity*Denomination),0) AS RIP
	,DestLifeCycleID
FROM Accounting.vw_AllTransactionDenominations
WHERE ValueTypeID in (7,40) --euro banconote e monete
AND OpTypeID = 5 -- ripristino
GROUP BY DestLifeCycleID
) rip ON rip.DestLifeCycleID = lf.LifeCycleID
--sum all acconti
LEFT OUTER JOIN
( 
	SELECT ISNULL(SUM(Quantity*Denomination),0)  AS Recv,
		--i am the source of an account	
		SourceLifeCycleID
	FROM Accounting.vw_AllTransactionDenominations
	WHERE 
	(
		ValueTypeID in (7,40) --euro banconote e monete
		AND OpTypeID = 1 --accont
		AND DestLifeCycleID IS NOT NULL --count only not pending transactions
	) 
	GROUP BY SourceLifeCycleID
) recv ON recv.SourceLifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN
( 
	SELECT ISNULL(SUM(Quantity*Denomination),0)  AS Recv2,
	--I am the destination of a versamento
		DestLifeCycleID
	FROM Accounting.vw_AllTransactionDenominations
	WHERE 
	(
		ValueTypeID in (7,40) --euro banconote e monete
		AND OpTypeID = 4 --versamenti
	)
	GROUP BY DestLifeCycleID
) recv2 ON recv2.DestLifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--sum all versamenti
	SELECT ISNULL(SUM(Quantity*Denomination),0) AS given,
	--i am the source of a versamento	
	SourceLifeCycleID
	FROM
	Accounting.vw_AllTransactionDenominations
	WHERE 
	(

		ValueTypeID in (7,40) --euro banconote e monete
		AND OpTypeID = 4 --versamenti
		AND DestLifeCycleID IS NOT NULL --count only not pending transactions
	)
	GROUP BY SourceLifeCycleID
) given ON given.SourceLifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN
(
	--sum all versamenti
	SELECT ISNULL(SUM(Quantity*Denomination),0) AS given2,
	--i am the destiantion of an acconto
	DestLifeCycleID
	FROM
	Accounting.vw_AllTransactionDenominations
	WHERE 
	(
		ValueTypeID in (7,40) --euro banconote e monete
		AND OpTypeID = 1 --accont
	)
	GROUP BY DestLifeCycleID
)given2 ON given2.DestLifeCycleID = lf.LifeCycleID
--add all acquisti
LEFT OUTER JOIN 
(
	SELECT  ISNULL(SUM(CAST(t.ImportoEuroCents AS FLOAT) / 100),0) AS AcquistiEuro,
		  ISNULL(COUNT(*),0) AS CountAcquisti,
		  t.LifeCycleID
	FROM Accounting.tbl_EuroTransactions t
	WHERE t.OpTypeID = 11 -- it is an acquisto
	AND t.CancelID IS NULL
	AND t.PhysicalEuros = 1
	GROUP BY t.LifeCycleID
) acq ON acq.LifeCycleID = lf.LifeCycleID
--go with redemption
LEFT OUTER JOIN 
(
	SELECT  ISNULL(SUM(CAST(ImportoEuroCents AS FLOAT) / 100),0) AS RedemptionsEuro,
			ISNULL(COUNT(*),0) AS RedemptionCount,
			LifeCycleID
	FROM Accounting.tbl_EuroTransactions
	WHERE (OpTypeID = 12) -- it is a redemption
	AND PhysicalEuros = 1
	AND CancelID IS NULL
	GROUP BY LifeCycleID
) rede ON rede.LifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN 
(
	SELECT  ISNULL(SUM(CAST(v.ImportoEuroCents AS FLOAT) / 100),0) AS VenditeEuro,
			ISNULL(COUNT(*),0) AS VenditeCount,
			ISNULL(SUM(CAST(v.ImportoEuroCents AS FLOAT) / 100*(v.ExchangeRate - e.IntRate)),0) AS  UtileCambio,
			v.LifeCycleID
	FROM Accounting.tbl_EuroTransactions v
	INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = v.LifeCycleID
	INNER JOIN Accounting.tbl_CurrencyGamingdateRates e ON l.GamingDate = e.GamingDate AND e.CurrencyID = 0
	WHERE (v.OpTypeID = 13 ) -- it is avendita
	AND v.CancelID IS NULL
	GROUP BY v.LifeCycleID
) ven ON ven.LifeCycleID = lf.LifeCycleID

WHERE lf.StockTypeID IN (4,7)
GO
