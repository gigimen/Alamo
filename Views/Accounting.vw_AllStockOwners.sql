SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllStockOwners]
WITH SCHEMABINDING
AS
SELECT  Accounting.tbl_LifeCycles.LifeCycleID,
	Accounting.tbl_LifeCycles.GamingDate,
	AP.LifeCycleSnapshotID,
--	Aperture.SnapshotTypeID,
	--CUGID.RoleName + ' :' + CUID.FirstName + ' ' + CUID.LastName AS Confirmator,
        Accounting.tbl_LifeCycles.StockID, 
	CasinoLayout.Stocks.Tag, 
	CasinoLayout.Stocks.StockTypeID, 
	GeneralPurpose.fn_UTCToLocal(1,AP.SnapshotTime) AS AperturaTime,
	FloorActivity.tbl_UserAccesses.UserID			AS FirstOwner,
	APUID.FirstName + ' ' + APUID.LastName 	AS FirstResponsible,
	APUID.loginName 			AS FirstResponsibleLogin,
	APConfUID.FirstName + ' ' + APConfUID.LastName 	AS AperturaConfirmator,
	Accounting.tbl_Snapshot_Confirmations.UserID 	AS OtherOwner,
	GeneralPurpose.fn_UTCToLocal(1,ChangeOwners.SnapshotTime) AS ChangOwnerTime,
	COUID.FirstName + ' ' + COUID.LastName 	AS OtherResponsible,
	COUID.loginName			 	AS OtherResponsibleLogin,
	COloginUID.UserID			AS COUserID,
	COloginUID.FirstName + ' ' + COloginUID.LastName AS ChangeOwnerLogin,
	GeneralPurpose.fn_UTCToLocal(1,Chiusura.SnapshotTime) AS CloseTime,
	Chiusura.SnapshotTime AS CloseTimeUTC
FROM   	Accounting.tbl_LifeCycles
	INNER JOIN CasinoLayout.Stocks ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
	INNER JOIN Accounting.tbl_Snapshots AP
	ON AP.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
	AND AP.SnapshotTypeID = 1 --APERTURA
	INNER JOIN FloorActivity.tbl_UserAccesses ON FloorActivity.tbl_UserAccesses.UserAccessID = AP.UserAccessID
	INNER JOIN CasinoLayout.Users APUID ON APUID.UserID = FloorActivity.tbl_UserAccesses.UserID
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations APConf
	ON APConf.LifeCycleSnapshotID = AP.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users APConfUID 
	ON APConfUID.UserID = APConf.UserID
	LEFT OUTER JOIN Accounting.tbl_Snapshots ChangeOwners
	ON ChangeOwners.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
	AND ChangeOwners.SnapshotTypeID = 4 --CHANGEOWNER
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations 
	ON Accounting.tbl_Snapshot_Confirmations.LifeCycleSnapshotID = ChangeOwners.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users COUID 
	ON COUID.UserID = Accounting.tbl_Snapshot_Confirmations.UserID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses COlogin ON COlogin.UserAccessID = ChangeOwners.UserAccessID
	LEFT OUTER JOIN CasinoLayout.Users COloginUID ON COloginUID.UserID = COlogin.UserID
	LEFT OUTER JOIN Accounting.tbl_Snapshots Chiusura
	ON Chiusura.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
	AND Chiusura.SnapshotTypeID = 3 --Chiusura
GO
