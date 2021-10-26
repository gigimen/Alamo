SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_EuroCasseCheck]
--WITH SCHEMABINDING
AS
SELECT lf.Tag,
	lf.GamingDate,
	lf.LifeCycleID,
	ISNULL(rip.rip,0) AS ripristino,
	ISNULL(verSrc.ver,0) AS SrcVersamenti,
	ISNULL(verDest.ver,0) AS DestVersamenti,
	ISNULL(accSrc.acc,0) AS SrcAcconti,
	ISNULL(accDest.acc,0) AS DestAcconti,
	ISNULL(acq.acq,0) AS acquisti,
	ISNULL(rede.rede,0) AS redemptions,
	ISNULL(ven.ven,0) AS vendite,
	ISNULL(conChips.con,0) AS ConsegnaChipsEuro,
	ISNULL(chiChips.chi,0) AS ChiusuraChipsEuro,
	ISNULL(apChips.TotaleIniziale,0) AS AperturaChipsEuro,
	ISNULL(skipChips.[NonFisicalEuroForChips],0) AS skipChipsEuro,
	ISNULL(chiChips.chi,0) 
	+ ISNULL(conChips.con,0) 
	- ISNULL(apChips.TotaleIniziale,0)
	- ISNULL(skipChips.[NonFisicalEuroForChips],0) AS fluttChipsEuro,
	ISNULL(rip.rip,0) 
	+ ISNULL(accSrc.acc,0) 
	- ISNULL(accDest.acc,0) 
	- ISNULL(verSrc.ver,0) 
	+ ISNULL(verDest.ver,0)
	+ ISNULL(acq.acq,0) 
	- ISNULL(ven.ven,0) 
	- ISNULL(rede.rede,0) 
	--subtract the fluttuazione gettoni euro
	-
	(
		ISNULL(chiChips.chi,0) 
		+ ISNULL(conChips.con,0) 
		- ISNULL(apChips.TotaleIniziale,0)
		- ISNULL(skipChips.[NonFisicalEuroForChips],0) 	
	)
	AS ChiusuraTeorica,
	ISNULL(chi.chi,0) AS ChiusuraContata,
	ISNULL(chi.chi,0) -
	(
		ISNULL(rip.rip,0) 
		+ ISNULL(accSrc.acc,0) 
		- ISNULL(accDest.acc,0) 
		- ISNULL(verSrc.ver,0) 
		+ ISNULL(verDest.ver,0)
		+ ISNULL(acq.acq,0) 
		- ISNULL(rede.rede,0)
		- ISNULL(ven.ven,0)
		--subtract the fluttuazione gettoni euro
		-
		(
			ISNULL(chiChips.chi,0) 
			+ ISNULL(conChips.con,0) 
			- ISNULL(apChips.TotaleIniziale,0)
			- ISNULL(skipChips.[NonFisicalEuroForChips],0) 	
		)
	)
	 AS Differenza,
	 ven.UtileCambio

FROM Accounting.vw_AllStockLifeCycles lf
LEFT OUTER JOIN
(
--first get euro present in ripristino
--sum up ripristino and acconto
SELECT ISNULL(SUM(Quantity*Denomination),0) AS rip,
	DestLifeCycleID AS LifeCycleID
FROM
Accounting.vw_AllTransactionDenominations
WHERE ValueTypeID = 7 --euros
AND OpTypeID = 5 -- ripristino
GROUP BY DestLifeCycleID
) rip ON lf.LifeCycleID = rip.LifeCycleID
LEFT OUTER JOIN
(
--sum all acconti of which I am a the source
SELECT ISNULL(SUM(Quantity*Denomination),0) AS acc,
	SourceLifeCycleID AS LifeCycleID
FROM
Accounting.vw_AllTransactionDenominations
WHERE 
	--i am the source of an account
	ValueTypeID = 7 --euros
	AND OpTypeID = 1 --accont
	AND DestLifeCycleID IS NOT NULL --count only not pending transactions
GROUP BY 	SourceLifeCycleID
) accSrc ON accSrc.LifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN
(
--sum all acconti for which I am the destination
SELECT ISNULL(SUM(Quantity*Denomination),0) AS acc,
	DestLifeCycleID AS LifeCycleID
FROM
Accounting.vw_AllTransactionDenominations
WHERE 	--i am the destiantion of an acconto
	ValueTypeID = 7 --euros
	AND OpTypeID = 1 --acconto
GROUP BY DestLifeCycleID
) accDest
ON accDest.LifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN
(
--sum all versamenti of which I am a the source
SELECT ISNULL(SUM(Quantity*Denomination),0) AS ver,
	SourceLifeCycleID AS LifeCycleID
FROM
Accounting.vw_AllTransactionDenominations
WHERE 
	--i am the source of an account
	ValueTypeID = 7 --euros
	AND OpTypeID = 4 --versamenti
	AND DestLifeCycleID IS NOT NULL --count only not pending transactions
GROUP BY 	SourceLifeCycleID
) verSrc ON verSrc.LifeCycleID = lf.LifeCycleID
LEFT OUTER JOIN
(
--sum all versamenti for which I am the destination
SELECT ISNULL(SUM(Quantity*Denomination),0) AS ver,
	DestLifeCycleID AS LifeCycleID
FROM
Accounting.vw_AllTransactionDenominations
WHERE 	--i am the destiantion of an acconto
	ValueTypeID = 7 --euros
	AND OpTypeID = 4 --versamenti
GROUP BY DestLifeCycleID
) verDest ON verDest.LifeCycleID = lf.LifeCycleID

LEFT OUTER JOIN 
(
--go with acquisti
SELECT ISNULL(SUM(CAST(ImportoEuroCents AS FLOAT) / 100),0) AS acq,
	LifeCycleID
FROM Accounting.tbl_EuroTransactions
WHERE   
OpTypeID = 11 -- it is an acquisto
AND CancelID IS NULL
AND PhysicalEuros = 1
GROUP BY LifeCycleID
) acq ON lf.LifeCycleID = acq.LifeCycleID
LEFT OUTER JOIN 
(
--go with redemption
SELECT ISNULL(SUM(CAST(ImportoEuroCents AS FLOAT) / 100),0) AS rede,
LifeCycleID
FROM Accounting.tbl_EuroTransactions
WHERE  (OpTypeID = 12) -- it is a redemption 
AND PhysicalEuros = 1
AND CancelID IS NULL
GROUP BY LifeCycleID
) rede ON lf.LifeCycleID = rede.LifeCycleID
LEFT OUTER JOIN 
(
--go with redemption and calculate utilecambio
SELECT ISNULL(SUM(CAST(t.ImportoEuroCents AS FLOAT) / 100),0) AS ven,
	ISNULL(SUM(CAST(t.ImportoEuroCents AS FLOAT) / 100 * (t.ExchangeRate - e.IntRate)),0) AS UtileCambio,
	t.LifeCycleID
FROM Accounting.tbl_EuroTransactions t
INNER JOIN Accounting.tbl_LifeCycles lf ON t.LifeCycleID = lf.LifeCycleID 
INNER JOIN Accounting.tbl_CurrencyGamingdateRates e ON e.GamingDate = lf.GamingDate AND e.CurrencyID = 0 --euros
WHERE  OpTypeID = 13 -- it is a vendita
AND PhysicalEuros = 1
AND CancelID IS NULL
GROUP BY t.LifeCycleID
) ven ON lf.LifeCycleID = ven.LifeCycleID
LEFT OUTER JOIN
(
	--finally go with Chiusura
	SELECT ISNULL(SUM(Quantity*Denomination),0) AS chi,
		SourceLifeCycleID AS LifeCycleID
	FROM
	Accounting.vw_AllTransactionDenominations
	WHERE ValueTypeID = 7 --euros
	AND OpTypeID = 6 -- Consegna
	GROUP BY SourceLifeCycleID
) chi ON lf.LifeCycleID = chi.LifeCycleID

--no we have also chips euro to take into account
LEFT OUTER JOIN 
(
	--count first all in Consegna
	SELECT ISNULL(SUM(Quantity*Denomination),0) AS con,
		SourceLifeCycleID AS LifeCycleID
	FROM
	Accounting.vw_AllTransactionDenominations
	WHERE ValueTypeID = 36 --Gettoni gioco €
	AND OpTypeID = 6 -- Consegna
	GROUP BY SourceLifeCycleID
) conChips ON lf.LifeCycleID = conChips.LifeCycleID
LEFT OUTER JOIN 
(
	--count gettoni in Chiusura
	SELECT ISNULL(SUM(Quantity*Denomination),0) AS chi,
		LifeCycleID
	FROM
	Accounting.vw_AllSnapshotDenominations
	WHERE ValueTypeID = 36 --Gettoni gioco €
	AND SnapshotTypeID = 3 -- Chiusura
	GROUP BY LifeCycleID
) chiChips ON lf.LifeCycleID = chiChips.LifeCycleID
LEFT OUTER JOIN
(
	--see what was in apertura
	SELECT  
	sc.StockCompositionID, 
	ISNULL(SUM(d.Denomination * sd.InitialQty),0) AS TotaleIniziale
	FROM  CasinoLayout.StockCompositions sc
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations sd ON sc.StockCompositionID = sd.StockCompositionID 
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations d ON sd.DenoID = d.DenoID 
	WHERE d.ValueTypeID = 36 --Gettoni gioco €
	GROUP BY sc.StockCompositionID
) apChips ON lf.StockCompositionID = apChips.StockCompositionID
LEFT OUTER JOIN
(
	--take into account what not exchanged with fisical euros
	SELECT [LifeCycleID]
		  ,[NonFisicalEuroForChips]
	  FROM [Accounting].[vw_TotNonFisicalEuroForChips]
) skipChips ON lf.[LifeCycleID] = skipChips.[LifeCycleID]

WHERE lf.StockTypeID IN( 4,7) AND lf.CloseSnapshotID IS NOT NULL
GO
