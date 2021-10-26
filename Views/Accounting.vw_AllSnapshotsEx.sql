SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllSnapshotsEx]
WITH SCHEMABINDING
AS

--coretoo i lcase

SELECT  ss.LifeCycleSnapshotID,
	ss.SnapshotTypeID,
	ss.LifeCycleID,
	ss.SnapshotTime 				AS SnapshotTimeUTC, 
	ss.SnapshotTimeLoc, 
	ss.UserAccessID,
	CasinoLayout.SnapshotTypes.FName,
	lf.StockID, 
	st.Tag, 
	st.StockTypeID, 
	st.MinBet, 
	lf.GamingDate,
	USOWN.UserID 				AS OwnerUserID,
	USOWN.LastName 	+ ' ' + USOWN.FirstName	AS OwnerName,
	OWNSites.ComputerName,
        GeneralPurpose.fn_UTCToLocal(1,UAOWN.LoginDate) 	AS LoginDateLoc,
	GeneralPurpose.fn_UTCToLocal(1,UAOWN.LogoutDate) 	AS LogoutDateLoc,
	UAOWN.UserGroupID 			AS OwnerUserGroupID,
	USCONF.UserID 				AS ConfirUserID,
	USCONF.FirstName + ' ' + USCONF.LastName AS ConfirName,
	Accounting.tbl_Snapshot_Confirmations.UserGroupID AS ConfirUserGroupID, 
	CASE lf.GamingDate
		WHEN GeneralPurpose.fn_GetGamingLocalDate2(
				GETUTCDATE(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GETUTCDATE(),GETDATE()),
				st.StockTypeID) THEN 1
	ELSE 0
	END AS IsToday,
	CASE WHEN Ch.LifeCycleSnapshotID IS NULL THEN 1
		ELSE 0
	END  AS IsStockOpen,
	ISNULL(SUM(CASE WHEN vt.CurrencyID = 0 THEN ssv.Quantity * den.Denomination * scd.WeightInTotal ELSE 0 end),0)  AS TotalEUR  ,   
	ISNULL(SUM(CASE WHEN vt.CurrencyID <> 0 THEN ssv.Quantity * den.Denomination * ssv.ExchangeRate *scd.WeightInTotal ELSE 0 END),0) AS TotalCHF      
FROM Accounting.tbl_Snapshots ss   
	INNER JOIN  Accounting.tbl_LifeCycles lf	ON ss.LifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID 
	INNER JOIN CasinoLayout.SnapshotTypes  ON ss.SnapshotTypeID = CasinoLayout.SnapshotTypes.SnapshotTypeID
	INNER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = ss.UserAccessID 
	INNER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
	INNER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
	LEFT OUTER JOIN Accounting.tbl_SnapshotValues ssv	ON ssv.LifeCycleSnapshotID = ss.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations den ON ssv.DenoID = den.DenoID
	LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = lf.StockCompositionID AND scd.DenoID = den.DenoID
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations ON Accounting.tbl_Snapshot_Confirmations.LifeCycleSnapshotID = ss.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users USCONF ON Accounting.tbl_Snapshot_Confirmations.UserID = USCONF.UserID 
	LEFT OUTER JOIN Accounting.tbl_Snapshots Ch ON Ch.LifeCycleID = lf.LifeCycleID AND Ch.SnapshotTypeID = 3 /*Chiusura*/ AND Ch.LCSnapShotCancelID IS NULL
WHERE   --snapshot has not been cancelled
	ss.LCSnapShotCancelID IS NULL
GROUP BY
	ss.LifeCycleSnapshotID,
	ss.SnapshotTypeID,
	ss.LifeCycleID, 
	ss.SnapshotTime,
	ss.SnapshotTimeLoc, 
	ss.UserAccessID,
	CasinoLayout.SnapshotTypes.FName,
	lf.StockID, 
	st.Tag, 
	st.StockTypeID, 
	st.MinBet, 
	lf.GamingDate,
	USOWN.UserID,
	USOWN.LastName,
	USOWN.FirstName,
	OWNSites.ComputerName,
        UAOWN.LoginDate,
	UAOWN.LogoutDate,
	UAOWN.UserGroupID,
	USCONF.UserID,
	USCONF.FirstName,
	USCONF.LastName,
	Accounting.tbl_Snapshot_Confirmations.UserGroupID, 
	Ch.LifeCycleSnapshotID
GO
