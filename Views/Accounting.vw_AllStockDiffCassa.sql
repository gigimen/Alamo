SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_AllStockDiffCassa]
WITH SCHEMABINDING
AS
SELECT 	
	ch.Tag, 
	ch.StockID,
	ch.StockTypeID,
	ch.GamingDate,
	DATEPART(mm,ch.GamingDate) AS GamingMonth,
	DATEPART(yy,ch.GamingDate) AS GamingYear,
	ch.LifeCycleID,
	ch.StockCompositionID,
	ch.LifeCycleSnapshotID		AS ChiusuraSSID,
	ch.SnapshotTimeLoc 			AS CloseTime,
	ch.OwnerUserID, 
	ch.OwnerName, 
	ch.InitialStock, 
    ch.TotChiusura,
	con.ConsegnaTRID,
	con.TotConsegna/*,
	rip.RipristinoTRID,
	rip.TotRiristino*/,
	con.TotConsegna + 
	ch.TotChiusura - 
	ch.InitialStock AS DiffCassa
FROM   
(
SELECT 
	sto.Tag, 
	lf.StockID,
	sto.StockTypeID,
	lf.GamingDate,
	lf.StockCompositionID,
	ch.LifeCycleID,
	ch.LifeCycleSnapshotID,
	ch.SnapshotTimeLoc,
	UA.UserID AS OwnerUserID, 
	US.LastName + ' ' + US.FirstName AS OwnerName, 
	SUM(scd.InitialQty * deno.Denomination ) AS InitialStock, 
    SUM(chV.Quantity * chV.ExchangeRate * deno.Denomination * scd.WeightInTotal) AS TotChiusura 
FROM Accounting.tbl_Snapshots ch 
	INNER JOIN Accounting.tbl_LifeCycles lf ON ch.LifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks sto ON lf.StockID = sto.StockID 
	INNER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID
	INNER JOIN CasinoLayout.tbl_Denominations deno ON deno.DenoID = scd.DenoID
	INNER JOIN FloorActivity.tbl_UserAccesses UA ON UA.UserAccessID = ch.UserAccessID 
	INNER JOIN CasinoLayout.Users US	ON US.UserID = UA.UserID 
	LEFT OUTER JOIN Accounting.tbl_SnapshotValues chV ON chV.LifeCycleSnapshotID = ch.LifeCycleSnapshotID AND scd.DenoID = chV.DenoID 
WHERE ch.SnapshotTypeID = 3 
	AND ch.LCSnapShotCancelID IS NULL --only Chiusura snapshots	
	AND sto.StockTypeID IN (4,7)
	AND scd.IsRiserva = 0
GROUP BY sto.Tag, 
	lf.StockID,
	sto.StockTypeID,
	lf.GamingDate,
	lf.StockCompositionID,
	ch.LifeCycleID,
	ch.LifeCycleSnapshotID,
	ch.SnapshotTimeLoc,UA.UserID,
	US.LastName,
	US.FirstName
) ch
LEFT OUTER JOIN
(
SELECT 
	lf.LifeCycleID,
	Con.TransactionID AS ConsegnaTRID,
	ISNULL(SUM(conV.Quantity * conV.ExchangeRate * deno.Denomination * scd.WeightInTotal),0) AS TotConsegna 
FROM Accounting.tbl_Transactions con 
	INNER JOIN Accounting.tbl_LifeCycles lf ON con.SourceLifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID
	INNER JOIN CasinoLayout.tbl_Denominations deno ON deno.DenoID = scd.DenoID
	LEFT OUTER JOIN Accounting.tbl_TransactionValues conV ON conv.TransactionID = con.TransactionID AND conV.DenoID = scd.DenoID
	
WHERE con.TrCancelID IS NULL 
AND con.OpTypeID = 6 --Consegna
AND scd.IsRiserva = 0
GROUP BY lf.LifeCycleID,con.TransactionID
) con ON con.LifeCycleID = ch.LifeCycleID
GO
