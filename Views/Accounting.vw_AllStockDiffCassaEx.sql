SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Accounting].[vw_AllStockDiffCassaEx]
WITH SCHEMABINDING
AS
/*

select * from [Accounting].[vw_AllStockDiffCassaEx] where GamingDate = '1.7.2019'

*/
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
	ISNULL(ch.InitialStock,0)	AS InitialStock, 
    ISNULL(ch.TotChiusura,0)	AS TotChiusura,
	con.ConsegnaTRID,
	ISNULL(con.TotConsegna,0)	AS TotConsegna,
	ISNULL(con.TotConsegna,0) + 
	ISNULL(ch.TotChiusura,0) - 
	ISNULL(ch.InitialStock,0)				AS DiffCassa,
	ch.CurrencyID,
	ISNULL(ch.Acronim, con.Acronim)				AS Acronim
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
		SUM(
		CASE 
		WHEN vt.CurrencyID IN(0,4) 
			THEN chV.Quantity * deno.Denomination * scd.WeightInTotal
		ELSE
			chV.Quantity * chV.ExchangeRate * deno.Denomination * scd.WeightInTotal
		END
		) AS TotChiusura,
		CASE WHEN vt.CurrencyID <> 0 THEN 4 --all in chf
		ELSE 0 END AS CurrencyID,
		CASE WHEN vt.CurrencyID <> 0 THEN 'CHF' --all in chf
		ELSE 'EUR' END AS Acronim
	FROM Accounting.tbl_Snapshots ch 
		INNER JOIN Accounting.tbl_LifeCycles lf ON ch.LifeCycleID = lf.LifeCycleID 
		INNER JOIN CasinoLayout.Stocks sto ON lf.StockID = sto.StockID 
		INNER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID
		INNER JOIN CasinoLayout.tbl_Denominations deno ON deno.DenoID = scd.DenoID
		INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = deno.ValueTypeID
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
		US.FirstName,
		CASE WHEN vt.CurrencyID <> 0 THEN 4 --all in chf
		ELSE 0 END,
		CASE WHEN vt.CurrencyID <> 0 THEN 'CHF' --all in chf
		ELSE 'EUR' END 
) ch
LEFT OUTER JOIN
(
	SELECT 
		lf.LifeCycleID,
		Con.TransactionID AS ConsegnaTRID,
		ISNULL(SUM(conV.Quantity * conV.ExchangeRate * deno.Denomination * scd.WeightInTotal),0) AS TotConsegna,
		CASE WHEN vt.CurrencyID <> 0 THEN 4 --all in chf
		ELSE 0 END AS CurrencyID,
		CASE WHEN vt.CurrencyID <> 0 THEN 'CHF' --all in chf
		ELSE 'EUR' END AS Acronim
	FROM Accounting.tbl_Transactions con 
		INNER JOIN Accounting.tbl_LifeCycles lf ON con.SourceLifeCycleID = lf.LifeCycleID 
		INNER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID
		INNER JOIN CasinoLayout.tbl_Denominations deno ON deno.DenoID = scd.DenoID
		INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = deno.ValueTypeID
		LEFT OUTER JOIN Accounting.tbl_TransactionValues conV ON conv.TransactionID = con.TransactionID AND conV.DenoID = scd.DenoID
	
	WHERE con.TrCancelID IS NULL 
	AND con.OpTypeID = 6 --Consegna
	AND scd.IsRiserva = 0
	GROUP BY 
		lf.LifeCycleID,
		con.TransactionID,
		CASE WHEN vt.CurrencyID <> 0 THEN 4 --all in chf
		ELSE 0 END,
		CASE WHEN vt.CurrencyID <> 0 THEN 'CHF' --all in chf
		ELSE 'EUR' END
) con ON con.LifeCycleID = ch.LifeCycleID AND ch.CurrencyID = con.CurrencyID
GO
