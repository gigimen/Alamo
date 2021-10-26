SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllSnapshots]
WITH SCHEMABINDING
AS
SELECT  Accounting.tbl_Snapshots.LifeCycleSnapshotID,
	Accounting.tbl_Snapshots.SnapshotTypeID,
	Accounting.tbl_Snapshots.LifeCycleID,
	Accounting.tbl_Snapshots.SnapshotTime 				as SnapshotTimeUTC, 
	Accounting.tbl_Snapshots.SnapshotTimeLoc, 
	Accounting.tbl_Snapshots.UserAccessID,
	CasinoLayout.SnapshotTypes.FName,
	Accounting.tbl_LifeCycles.StockID, 
	CasinoLayout.Stocks.Tag, 
	CasinoLayout.Stocks.StockTypeID, 
	CasinoLayout.Stocks.MinBet, 
	Accounting.tbl_LifeCycles.GamingDate,
	USOWN.UserID 				AS OwnerUserID,
	USOWN.LastName 	+ ' ' + USOWN.FirstName	as OwnerName,
	OWNSites.ComputerName,
        GeneralPurpose.fn_UTCToLocal(1,UAOWN.LoginDate) 	as LoginDateLoc,
	GeneralPurpose.fn_UTCToLocal(1,UAOWN.LogoutDate) 	as LogoutDateLoc,
	UAOWN.UserGroupID 			AS OwnerUserGroupID,
	USCONF.UserID 				AS ConfirUserID,
	USCONF.FirstName + ' ' + USCONF.LastName as ConfirName,
	Accounting.tbl_Snapshot_Confirmations.UserGroupID AS ConfirUserGroupID, 
	case Accounting.tbl_LifeCycles.GamingDate
		when GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				CasinoLayout.Stocks.StockTypeID) then 1
	else 0
	end as IsToday,
	case when Ch.LifeCycleSnapshotID is null then 1
		else 0
	end  as IsStockOpen,
	SUM(Accounting.tbl_SnapshotValues.Quantity * den.Denomination * Accounting.tbl_SnapshotValues.ExchangeRate *CasinoLayout.StockComposition_Denominations.WeightInTotal ) 	AS TotalCHF       
FROM    Accounting.tbl_LifeCycles 
	INNER JOIN CasinoLayout.Stocks
	ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID 
	INNER JOIN Accounting.tbl_Snapshots  
	ON Accounting.tbl_Snapshots.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID 
	INNER JOIN CasinoLayout.SnapshotTypes  
	ON Accounting.tbl_Snapshots.SnapshotTypeID = CasinoLayout.SnapshotTypes.SnapshotTypeID
	INNER JOIN FloorActivity.tbl_UserAccesses UAOWN
	ON UAOWN.UserAccessID = Accounting.tbl_Snapshots.UserAccessID 
	INNER JOIN CasinoLayout.Users USOWN
	ON USOWN.UserID = UAOWN.UserID 
	INNER JOIN CasinoLayout.Sites OWNSites
	ON OWNSites.SiteID = UAOWN.SiteID 
	LEFT OUTER JOIN Accounting.tbl_SnapshotValues 
	ON Accounting.tbl_SnapshotValues.LifeCycleSnapshotID = Accounting.tbl_Snapshots.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations den 
	ON Accounting.tbl_SnapshotValues.DenoID = den.DenoID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations 
	ON CasinoLayout.StockComposition_Denominations.StockCompositionID = Accounting.tbl_LifeCycles.StockCompositionID and CasinoLayout.StockComposition_Denominations.DenoID = den.DenoID
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations 
	ON Accounting.tbl_Snapshot_Confirmations.LifeCycleSnapshotID = Accounting.tbl_Snapshots.LifeCycleSnapshotID
	LEFT OUTER JOIN CasinoLayout.Users USCONF
	ON Accounting.tbl_Snapshot_Confirmations.UserID = USCONF.UserID 
	LEFT OUTER JOIN Accounting.tbl_Snapshots	Ch	
	ON Ch.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID and Ch.SnapshotTypeID = 3 /*Chiusura*/ and Ch.LCSnapShotCancelID is null
WHERE   --snapshot has not been cancelled
	Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
group by
	Accounting.tbl_Snapshots.LifeCycleSnapshotID,
	Accounting.tbl_Snapshots.SnapshotTypeID,
	Accounting.tbl_Snapshots.LifeCycleID, 
	Accounting.tbl_Snapshots.SnapshotTime,
	Accounting.tbl_Snapshots.SnapshotTimeLoc, 
	Accounting.tbl_Snapshots.UserAccessID,
	CasinoLayout.SnapshotTypes.FName,
	Accounting.tbl_LifeCycles.StockID, 
	CasinoLayout.Stocks.Tag, 
	CasinoLayout.Stocks.StockTypeID, 
	CasinoLayout.Stocks.MinBet, 
	Accounting.tbl_LifeCycles.GamingDate,
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
