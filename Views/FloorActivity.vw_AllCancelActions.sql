SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [FloorActivity].[vw_AllCancelActions]
WITH SCHEMABINDING
AS
select top 100 percent cosa,
		CancelID,
		Tag, 
		FName, 
		Deno,
		GamingDate, 
		CancelDate,
		UserName,
		ComputerName 
from 
(
	SELECT  'Cancellazione Snapshot' as cosa,
		FloorActivity.tbl_Cancellations.CancelID,
		CasinoLayout.Stocks.Tag, 
		CasinoLayout.SnapshotTypes.FName, 
		null as Deno,
		Accounting.tbl_LifeCycles.GamingDate, 
		FloorActivity.tbl_Cancellations.CancelDateLoc as CancelDate,
		USOWN.Lastname + ' ' + USOWN.Firstname as UserName,
		OWNSites.ComputerName
	FROM    FloorActivity.tbl_Cancellations
		INNER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = FloorActivity.tbl_Cancellations.UserAccessID
		INNER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
		INNER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
	    INNER JOIN Accounting.tbl_Snapshots ON FloorActivity.tbl_Cancellations.CancelID = Accounting.tbl_Snapshots.LCSnapshotCancelID	
	    Left OUTER JOIN CasinoLayout.SnapshotTypes ON CasinoLayout.SnapshotTypes.SnapshotTypeID = Accounting.tbl_Snapshots.SnapshotTypeID
	    Left OUTER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_Snapshots.LifeCycleID
	    Left OUTER JOIN CasinoLayout.Stocks ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
	WHERE     Accounting.tbl_Snapshots.LCSnapshotCancelID IS NOT NULL
	UNION ALL
	SELECT  'Cancellazione Transazione' as cosa,
		FloorActivity.tbl_Cancellations.CancelID,
		CasinoLayout.Stocks.Tag, 
		CasinoLayout.OperationTypes.FName, 
		null as Deno,
		Accounting.tbl_LifeCycles.GamingDate, 
		FloorActivity.tbl_Cancellations.CancelDateLoc as CancelDate,
		USOWN.Lastname + ' ' + USOWN.Firstname as UserName,
		OWNSites.ComputerName
	FROM    FloorActivity.tbl_Cancellations 
		INNER JOIN Accounting.tbl_Transactions ON FloorActivity.tbl_Cancellations.CancelID = Accounting.tbl_Transactions.TrCancelID
		Left OUTER JOIN CasinoLayout.OperationTypes ON Accounting.tbl_Transactions.OpTypeID = CasinoLayout.OperationTypes.OpTypeID
		Left OUTER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_Transactions.SourceLifeCycleID
		Left OUTER JOIN CasinoLayout.Stocks ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
		Left OUTER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = FloorActivity.tbl_Cancellations.UserAccessID
		Left OUTER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
		Left OUTER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
	WHERE   Accounting.tbl_Transactions.TrCancelID IS NOT NULL
	UNION ALL
	SELECT  'Cancellazione CustTransaction' as cosa,
		FloorActivity.tbl_Cancellations.CancelID,
		CasinoLayout.Stocks.Tag, 
		CasinoLayout.OperationTypes.FName,
		D.FName as Deno, 
		Accounting.tbl_LifeCycles.GamingDate, 
		FloorActivity.tbl_Cancellations.CancelDateLoc as CancelDate,
		USOWN.Lastname + ' ' + USOWN.Firstname as UserName,
		OWNSites.ComputerName
	FROM    FloorActivity.tbl_Cancellations
	        INNER JOIN Snoopy.tbl_CustomerTransactions ON FloorActivity.tbl_Cancellations.CancelID = Snoopy.tbl_CustomerTransactions.CustTrCancelID
	         Left OUTER JOIN CasinoLayout.OperationTypes ON Snoopy.tbl_CustomerTransactions.OpTypeID = CasinoLayout.OperationTypes.OpTypeID 
	        Left OUTER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Snoopy.tbl_CustomerTransactions.SourceLifeCycleID 
	        Left OUTER JOIN CasinoLayout.Stocks ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID 
		Left OUTER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = FloorActivity.tbl_Cancellations.UserAccessID
		Left OUTER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
		Left OUTER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
	        Left OUTER JOIN Snoopy.tbl_CustomerTransactionValues V ON V.CustomerTransactionID = Snoopy.tbl_CustomerTransactions.CustomerTransactionID
	        Left OUTER JOIN CasinoLayout.tbl_Denominations D ON V.DenoID = D.DenoID
	WHERE   Snoopy.tbl_CustomerTransactions.CustTrCancelID IS NOT NULL
	UNION ALL
	SELECT  'Cancellazione registration' as cosa,
		FloorActivity.tbl_Cancellations.CancelID,
		CasinoLayout.Stocks.Tag, 
		ide.FDescription as FName,
		null as Deno, 
		Snoopy.tbl_Registrations.GamingDate, 
		FloorActivity.tbl_Cancellations.CancelDateLoc as CancelDate,
		USOWN.Lastname + ' ' + USOWN.Firstname as UserName,
		OWNSites.ComputerName
	FROM    FloorActivity.tbl_Cancellations
		INNER JOIN Snoopy.tbl_Registrations ON FloorActivity.tbl_Cancellations.CancelID = Snoopy.tbl_Registrations.CancelID
		inner join Snoopy.tbl_IDCauses ide on ide.IDCauseID = Snoopy.tbl_Registrations.CauseID
		inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = Snoopy.tbl_Registrations.StockID
		Left OUTER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = FloorActivity.tbl_Cancellations.UserAccessID
		Left OUTER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
		Left OUTER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
	WHERE   Snoopy.tbl_Registrations.CancelID IS NOT NULL
	UNION ALL
	SELECT  'Cancellazione transazione euro' as cosa,
		FloorActivity.tbl_Cancellations.CancelID,
		CasinoLayout.Stocks.Tag, 
		ot.FName,
		null as Deno, 
		lf.GamingDate, 
		FloorActivity.tbl_Cancellations.CancelDateLoc as CancelDate,
		USOWN.Lastname + ' ' + USOWN.Firstname as UserName,
		OWNSites.ComputerName
	FROM    FloorActivity.tbl_Cancellations
		INNER JOIN Accounting.tbl_EuroTransactions t ON FloorActivity.tbl_Cancellations.CancelID = t.CancelID
		INNER JOIN CasinoLayout.OperationTypes ot ON ot.OpTypeID = t.OpTypeID
		inner join Accounting.tbl_LifeCycles lf on lf.LifecYCLEId = t.LifeCycleID
		inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = lf.StockID
		Left OUTER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = FloorActivity.tbl_Cancellations.UserAccessID
		Left OUTER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
		Left OUTER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
	WHERE   t.CancelID IS NOT NULL
	UNION ALL
	SELECT  'Cancellazione customer' as cosa,
		FloorActivity.tbl_Cancellations.CancelID,
		NULL AS Tag, 
		NULL AS FName,
		null as Deno, 
		NULL AS GamingDate, 
		FloorActivity.tbl_Cancellations.CancelDateLoc as CancelDate,
		USOWN.Lastname + ' ' + USOWN.Firstname as UserName,
		OWNSites.ComputerName
	FROM    FloorActivity.tbl_Cancellations
		INNER JOIN Snoopy.tbl_Customers c ON FloorActivity.tbl_Cancellations.CancelID = c.CustCancelID
		Left OUTER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = FloorActivity.tbl_Cancellations.UserAccessID
		Left OUTER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
		Left OUTER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
	WHERE   c.CustCancelID IS NOT NULL

) F
order by F.CancelDate

GO
