SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [FloorActivity].[vw_AllLastStockOwners]
WITH SCHEMABINDING
AS
SELECT  
	lf.LifeCycleID,
	lf.GamingDate,
    lf.StockID, 
	st.Tag, 
	st.StockTypeID, 
	AP.LifeCycleSnapshotID											AS ApSnapshotID,
	GeneralPurpose.fn_UTCToLocal(1,AP.SnapshotTime)			AS ApTimeLoc,
	APUID.UserID													AS ApUserID,
	APUID.FirstName + ' ' + APUID.LastName 							AS ApUserName,
	APConfUID.UserID 												AS ApConfUserID,	
	APConfUID.FirstName + ' ' + APConfUID.LastName 					AS ApConfUserName,

	--here is Chiusura details
	ch.LifeCycleSnapshotID											AS ChSnapshotID,
	GeneralPurpose.fn_UTCToLocal(1,ch.SnapshotTime)			AS ChTimeLoc,
	chUID.UserID													AS ChUserID,
	chUID.FirstName + ' ' + chUID.LastName 							AS ChUserName,
	CHConfUID.UserID 												AS ChConfUserID,	
	CHConfUID.FirstName + ' ' + CHConfUID.LastName 					AS ChConfUserName,

	--here is last chowner snapshot details 
	a.LastSnapshotID												AS ChOwnSnapshotID,
	GeneralPurpose.fn_UTCToLocal(1,chown.SnapshotTime)			AS ChOwnTimeLoc,
	chUID.FirstName + ' ' + chUID.LastName 							AS ChOwnUserName,
	chUID.UserID			 										AS ChOwnUserID,
	chownConfUID.UserID 											AS ChOwnConfUserID,	
	chownConfUID.FirstName + ' ' + chownConfUID.LastName 			AS ChOwnConfUserName

FROM   	Accounting.tbl_LifeCycles lf
	INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID
	INNER JOIN Accounting.tbl_Snapshots AP	ON AP.LifeCycleID = lf.LifeCycleID
	AND AP.SnapshotTypeID = 1 --APERTURA
	AND AP.LCSnapShotCancelID IS NULL
	INNER JOIN FloorActivity.tbl_UserAccesses apuaid ON apuaid.UserAccessID = AP.UserAccessID
	INNER JOIN CasinoLayout.Users APUID ON APUID.UserID = apuaid.UserID
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations APConf	ON APConf.LifeCycleSnapshotID = AP.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users APConfUID ON APConfUID.UserID = APConf.UserID

	--here goes Chiusura
	LEFT OUTER JOIN Accounting.tbl_Snapshots ch ON ch.LifeCycleID = lf.LifeCycleID
	AND ch.SnapshotTypeID = 3 --Chiusura
	and ch.LCSnapShotCancelID IS NULL
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses chuaid ON chuaid.UserAccessID = ch.UserAccessID
	LEFT OUTER JOIN CasinoLayout.Users chUID ON chUID.UserID = chuaid.UserID
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations CHConf	ON CHConf.LifeCycleSnapshotID = ch.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users CHConfUID ON CHConfUID.UserID = CHConf.UserID

	--here goes last change owner
	LEFT OUTER JOIN
	(
		--get last change owner snapshotid
		select 
			lf1.LifeCycleID,
			max(chown.LifeCycleSnapshotID) as LastSnapshotID
		from Accounting.tbl_Snapshots chown 
		inner join Accounting.tbl_LifeCycles lf1 on lf1.LifeCycleID = chown.LifeCycleID 
		where chown.SnapshotTypeID = 4 --CHANGEOWNER
		and chown.LCSnapShotCancelID IS NULL
		group by lf1.LifeCycleID	
	) a ON a.LifeCycleID = lf.LifeCycleID
	LEFT OUTER JOIN Accounting.tbl_Snapshots chown ON a.LastSnapshotID = chown.LifeCycleSnapshotID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses chownuaid ON chownuaid.UserAccessID = chown.UserAccessID
	LEFT OUTER JOIN CasinoLayout.Users chownUID ON chownuaid.UserID = chownUID.UserID
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations chownConf ON chownConf.LifeCycleSnapshotID = chown.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users chownConfUID ON chownConfUID.UserID = chownConf.UserID
GO
