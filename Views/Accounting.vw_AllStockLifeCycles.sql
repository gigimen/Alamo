SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [Accounting].[vw_AllStockLifeCycles]
WITH SCHEMABINDING
AS
SELECT  lf.LifeCycleID, 
	lf.StockID, 
	lf.StockCompositionID, 
	st.Tag, 
	st.StockTypeID, 
	st.KioskID,
	Chiusura.SnapshotTime as CloseTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,Chiusura.SnapshotTime) As CloseTime, 
	Chiusura.LifeCycleSnapshotID as CloseSnapshotID,
	Apertura.SnapshotTime As OpenTimeUTC, 
	GeneralPurpose.fn_UTCToLocal(1,Apertura.SnapshotTime) As OpenTime, 
	Apertura.LifeCycleSnapshotID as AperturaSnapshotID,
	lf.GamingDate, 
/*
        dbo.fn_IsGamingDateToday(
		dbo.LifeCycles.GamingDate, 
		GetUTCDate(), 
		DATEDIFF(hh, GetUTCDate(), GETDATE()),
		dbo.Stocks.StockTypeID) AS IsToday,
*/
	Apertura.UserAccessID,
	SO.FName as SiteName,
	AO.FName as ApplicationName,
	USOWN.UserID 				AS OwnerUserID,
	USOWN.FirstName + ' ' + USOWN.LastName 	as OwnerName,
	USOWN.loginName,
	UAO.UserGroupID 		AS OwnerUserGroupID,
	USCONF.UserID 				AS ConfirUserID,
	USCONF.FirstName + ' ' + USCONF.LastName as ConfirName,
	Accounting.tbl_Snapshot_Confirmations.UserGroupID AS ConfirUserGroupID
FROM    Accounting.tbl_LifeCycles lf
	INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID
	INNER JOIN Accounting.tbl_Snapshots Apertura 
	ON Apertura.LifeCycleID = lf.LifeCycleID and 
	Apertura.SnapshotTypeID = 1 --'Apertura'
	--apertura has not been cancelled
	AND Apertura.LCSnapShotCancelID IS NULL
	INNER JOIN FloorActivity.tbl_UserAccesses UAO
	ON UAO.UserAccessID = Apertura.UserAccessID 
	INNER JOIN CasinoLayout.Users USOWN
	ON UAO.UserID = USOWN.UserID 
	INNER JOIN CasinoLayout.Sites SO
	ON UAO.SiteID = SO.SiteID 
	INNER JOIN [GeneralPurpose].[Applications] AO
	ON UAO.ApplicationID = AO.ApplicationID 
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations 
	ON Accounting.tbl_Snapshot_Confirmations.LifeCycleSnapshotID = Apertura.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users USCONF
	ON Accounting.tbl_Snapshot_Confirmations.UserID = USCONF.UserID 
	LEFT OUTER JOIN Accounting.tbl_Snapshots Chiusura 
	ON Chiusura.LifeCycleID = lf.LifeCycleID and 
	Chiusura.SnapshotTypeID  = 3 --in (select SnapshotTypeID from SnapshotTypes where FName = 'Chiusura' )
	--Chiusura has not been cancelled
	AND Chiusura.LCSnapShotCancelID IS NULL
GO
