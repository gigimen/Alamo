SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllLifeCycleNonCancelledSnapshots]
WITH SCHEMABINDING
AS
SELECT  Accounting.tbl_Snapshots.LifeCycleSnapshotID,
	Accounting.tbl_Snapshots.SnapshotTypeID,
	Accounting.tbl_Snapshots.LifeCycleID, 
	Accounting.tbl_Snapshots.SnapshotTime 			 as SnapshotTimeUTC,
	Accounting.tbl_Snapshots.SnapshotTimeLoc, 
	Accounting.tbl_Snapshots.UserAccessID,
	Accounting.tbl_LifeCycles.GamingDate,
	Accounting.tbl_LifeCycles.StockID,
	Accounting.tbl_LifeCycles.StockCompositionID,
	CasinoLayout.Stocks.StockTypeID,
	CasinoLayout.Stocks.Tag
FROM	Accounting.tbl_Snapshots
        INNER JOIN Accounting.tbl_LifeCycles 
	ON Accounting.tbl_Snapshots.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks
	ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID 
WHERE   (Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL)
















GO
