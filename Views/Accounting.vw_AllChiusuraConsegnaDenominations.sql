SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [Accounting].[vw_AllChiusuraConsegnaDenominations]
WITH SCHEMABINDING
AS
SELECT 
st.Tag, 
lf.StockID,
st.StockTypeID,
lf.GamingDate,
lf.StockCompositionID,
DATEPART(mm,lf.GamingDate)		AS GamingMonth,
DATEPART(yy,lf.GamingDate)		AS GamingYear,
lf.LifeCycleID,
vt.ValueTypeID,
vt.FName		AS	ValueTypeName,
cu.CurrencyID,
cu.IsoName		AS CurrencyAcronim,
d.FDescription,
d.DenoID,
d.Denomination,
d.IsFisical,
ch.LifeCycleSnapshotID			AS ChiusuraSSID,
ch.SnapshotTimeLoc 				AS CloseTime,
CASE WHEN st.StockTypeID = 1 AND lf.GamingDate < '3.23.2017' THEN 'Chiusura Full' ELSE 'Chiusura e Consegna' END AS TipoConsegna,
CASE WHEN st.StockTypeID = 1 AND lf.GamingDate < '3.23.2017' THEN 
	ISNULL(chV.Quantity,0)	- ISNULL(conV.Quantity,0) 		
ELSE
	ISNULL(chV.Quantity,0)
END								AS InStock,
CASE WHEN st.StockTypeID = 1 AND lf.GamingDate < '3.23.2017' THEN
	ISNULL(chV.Quantity,0)			--before big change everything was stored into Chiusura for tables
ELSE
	ISNULL(chV.Quantity,0) + ISNULL(conV.Quantity,0) --after is splitted in Chiusura and Consegna
END								AS Chiusura,
ISNULL(chV.ExchangeRate,0.0) 	AS ERChiusura,
con.TransactionID				AS ConsegnaTRID,
ISNULL(conV.Quantity,0) 		AS Consegna,
ISNULL(conV.ExchangeRate,0) 	AS ERConsegna,
rip.TransactionID				AS RipristinoTRID,
ISNULL(ripV.Quantity,0)			AS Ripristino,
ISNULL(ripV.ExchangeRate,0)		AS ERRipristino,
CASE WHEN st.StockTypeID = 1 AND lf.GamingDate < '3.23.2017' THEN
	ISNULL(chV.Quantity,0) - ISNULL(conV.Quantity,0) + ISNULL(ripV.Quantity,0) 
ELSE
	ISNULL(chV.Quantity,0) + ISNULL(ripV.Quantity,0) 
END								AS Ripristinato,
sc.InitialQty,
sc.WeightInTotal,
sc.ModuleValue,
[Accounting].[fn_TableCalculateChiusuraRiserva]
(
d.DenoID,
ISNULL(chV.Quantity,0)+ISNULL(conV.Quantity,0),
sc.InitialQty,
sc.ModuleValue
) AS ChiusuraRiserva
FROM Accounting.tbl_LifeCycles lf
INNER JOIN CasinoLayout.Stocks st ON lf.StockID =st.StockID 
--get only those lf with a valid apertura
INNER JOIN Accounting.tbl_Snapshots ap ON ap.LifeCycleID = lf.LifeCycleID AND ap.SnapshotTypeID = 1 AND ap.LCSnapShotCancelID IS NULL
INNER JOIN CasinoLayout.StockComposition_Denominations sc	ON sc.StockCompositionID = lf.StockCompositionID
INNER JOIN CasinoLayout.tbl_Denominations d	ON d.DenoID = sc.DenoID
INNER JOIN CasinoLayout.tbl_ValueTypes vt	ON vt.ValueTypeID = d.ValueTypeID
INNER JOIN CasinoLayout.tbl_Currencies cu ON	cu.CurrencyID = vt.CurrencyID

--left outer join Accounting.vw_AllSnapshots ch on ch.LifeCycleID = lf.LifeCycleID and
LEFT OUTER JOIN Accounting.tbl_Snapshots ch ON ch.LifeCycleID = lf.LifeCycleID AND ch.SnapshotTypeID = 3 AND ch.LCSnapShotCancelID IS NULL
LEFT OUTER JOIN Accounting.tbl_SnapshotValues chV ON  chV.LifeCycleSnapshotID = ch.LifeCycleSnapshotID	
		AND sc.DenoID = chV.DenoID 

--THEN Consegna VALUES
--use left join to include also Consegna with Denomination with zero values
LEFT OUTER JOIN Accounting.tbl_Transactions con ON con.SourceLifeCycleID = lf.LifeCycleID  
	AND con.OpTypeID = 6 --Consegna
	AND con.TrCancelID IS NULL
LEFT OUTER JOIN Accounting.vw_AllTransactionDenominations conV ON conV.TransactionID = con.TransactionID
	AND conV.DenoID = sc.DenoID
	
--FINALLY RIPRISTINO
--use left join to include also ripristino with Denomination with zero values
LEFT OUTER JOIN Accounting.tbl_Transactions rip 
/*old way based on gamingdate
ON rip.DestStockID = lf.StockID 
	AND rip.SourceGamingDate = lf.GamingDate
	AND rip.OpTypeID = 5 --ripristino
	*/
--the ripristion has been created for me the same GamingDate of th Consegna by Mainstock
-- the lifecycle that accepted the consegna also created the ripristino
ON lf.StockID = rip.DestStockID AND con.DestLifeCycleID = rip.SourceLifeCycleID --LF.GamingDate = RIP.SourceGamingDate

LEFT OUTER JOIN Accounting.tbl_TransactionValues ripV ON ripV.TransactionID = rip.TransactionID 
	AND ripV.DenoID = sc.DenoID
WHERE sc.IsRiserva = 0
GO
