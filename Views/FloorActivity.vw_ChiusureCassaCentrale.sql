SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [FloorActivity].[vw_ChiusureCassaCentrale]
WITH SCHEMABINDING
AS
SELECT 
	LF.GamingDate,
	LF.LifeCycleID,
	lf.StockCompositionID,
	--CHI.TotalCHF as Chiusura,
	CHI.LifeCycleSnapshotID AS ChiusuraSnapshotID,
	CHI.SnapshotTimeLoc AS ChiusuraTime,
	CHI.SnapshotTime	AS ChiusuraTimeUTC,
	CHI.UserAccessID,
	ua.ComputerName,
	ua.UserName,
	conf.UserID,
	cu.FirstName + ' ' + cu.LastName as ConfUserName

FROM Accounting.tbl_LifeCycles LF
--consider only lifecycles with a valid apertura
INNER JOIN Accounting.tbl_Snapshots CHI 
	ON LF.LifeCycleID = CHI.LifeCycleID
	AND CHI.SnapshotTypeID = 3 --only Chiusura snapshots
	AND CHI.LCSnapShotCancelID IS NULL
INNER JOIN [FloorActivity].[vw_AllUserAccesses] ua on ua.UserAccessID = CHI.UserAccessID
LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations conf on conf.LifeCycleSnapshotID = CHI.LifeCycleSnapshotID
LEFT OUTER JOIN CasinoLayout.Users cu on cu.UserID = conf.UserID
where LF.StockID = 46 --solo cassa centrale
GO
