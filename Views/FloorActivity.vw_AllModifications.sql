SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [FloorActivity].[vw_AllModifications]
WITH SCHEMABINDING
AS
SELECT  'Modified Transaction' AS cosa,
	m.TransactionID,
	CASE WHEN CasinoLayout.OperationTypes.OpTypeID = 5 THEN ds.Tag	ELSE ss.Tag END AS Tag, 
	CASE WHEN CasinoLayout.OperationTypes.OpTypeID = 5 THEN ds.Stockid	ELSE ss.StockID END AS StockID, 
	CASE WHEN CasinoLayout.OperationTypes.OpTypeID = 5 THEN ds.[StockTypeID]	ELSE ss.[StockTypeID] END AS [StockTypeID], 
	CASE WHEN CasinoLayout.OperationTypes.OpTypeID = 5 THEN Accounting.tbl_Transactions.DestLifeCycleID ELSE Accounting.tbl_LifeCycles.LifeCycleid END AS LifeCycleid, 
	Accounting.tbl_LifeCycles.GamingDate,	
	CasinoLayout.OperationTypes.FName AS OperationName, 
	vt.FName AS ValueTypeName,
	den.FDescription AS Denomination,
	m.DenoID,
	m.CashInbound,
 	m.FromQuantity,
	m.ToQuantity,
	GeneralPurpose.fn_UTCToLocal(1,m.ModDate) AS ModDate,
	USOWN.Lastname + ' ' + USOWN.Firstname AS UserName,
	OWNSites.ComputerName
FROM FloorActivity.tbl_TransactionModifications m
	INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = m.DenoID
    INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID	
    INNER JOIN Accounting.tbl_Transactions ON Accounting.tbl_Transactions.TransactionID = m.TransactionID	
    INNER JOIN CasinoLayout.OperationTypes ON CasinoLayout.OperationTypes.OpTypeID = Accounting.tbl_Transactions.OpTypeID
    INNER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_Transactions.SourceLifeCycleID
    INNER JOIN CasinoLayout.Stocks sS ON Accounting.tbl_LifeCycles.StockID = sS.StockID
    INNER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = m.UserAccessID
	INNER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
	INNER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
    LEFT OUTER JOIN CasinoLayout.Stocks dS ON Accounting.tbl_Transactions.DestStockID = dS.StockID
UNION ALL
SELECT  'Modified Customer Transaction' AS cosa,
	m.CustomerTransactionID AS 	TransactionID,
	ss.Tag, 
	ss.StockID,
	ss.[StockTypeID],
	Snoopy.tbl_CustomerTransactions.SourceLifeCycleID AS LifeCycleid, 
	Accounting.tbl_LifeCycles.GamingDate,	
	CasinoLayout.OperationTypes.FName AS OperationName, 
	vt.FName AS ValueTypeName,
	den.FDescription AS Denomination,
	m.DenoID,
	m.CashInbound,
 	m.FromQuantity,
	m.ToQuantity,
	GeneralPurpose.fn_UTCToLocal(1,m.ModDate) AS ModDate,
	USOWN.Lastname + ' ' + USOWN.Firstname AS UserName,
	OWNSites.ComputerName
FROM FloorActivity.tbl_CustomerTransactionModifications m
	INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = m.DenoID
    INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID	
    INNER JOIN Snoopy.tbl_CustomerTransactions ON Snoopy.tbl_CustomerTransactions.CustomerTransactionID = m.CustomerTransactionID	
    INNER JOIN CasinoLayout.OperationTypes ON CasinoLayout.OperationTypes.OpTypeID = Snoopy.tbl_CustomerTransactions.OpTypeID
    INNER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID =Snoopy.tbl_CustomerTransactions.SourceLifeCycleID
    INNER JOIN CasinoLayout.Stocks sS ON Accounting.tbl_LifeCycles.StockID = sS.StockID
    INNER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = m.UserAccessID
	INNER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
	INNER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
UNION ALL
SELECT  'Modified Snapshot' AS cosa,
	m.LifeCycleSnapshotID AS 	TransactionID,
	ss.Tag, 
	ss.StockID,
	ss.[StockTypeID],
	Accounting.tbl_LifeCycles.LifeCycleid, 
	Accounting.tbl_LifeCycles.GamingDate,	
	CasinoLayout.SnapshotTypes.FName AS OperationName, 
	vt.FName AS ValueTypeName,
	den.FDescription AS Denomination,
	m.DenoID,
	NULL AS CashInbound,
 	m.FromQuantity,
	m.ToQuantity,
	GeneralPurpose.fn_UTCToLocal(1,m.ModDate) AS ModDate,
	USOWN.Lastname + ' ' + USOWN.Firstname AS UserName,
	OWNSites.ComputerName
FROM    FloorActivity.tbl_SnapshotModifications m
	INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = m.DenoID
    INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID	
    INNER JOIN Accounting.tbl_Snapshots ON Accounting.tbl_Snapshots.LifecycleSnapshotID = m.LifecycleSnapshotID	
    INNER JOIN CasinoLayout.SnapshotTypes ON CasinoLayout.SnapshotTypes.SnapshotTypeID = Accounting.tbl_Snapshots.SnapshotTypeID
    INNER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_Snapshots.LifeCycleID
    INNER JOIN CasinoLayout.Stocks ss ON Accounting.tbl_LifeCycles.StockID = ss.StockID
	INNER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = m.UserAccessID
	INNER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
	INNER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
UNION ALL
SELECT  'Modified Progress' AS cosa,
	0 AS TransactionID,
	ss.Tag, 
	ss.StockID,
	ss.[StockTypeID],
	Accounting.tbl_LifeCycles.LifeCycleid, 
	Accounting.tbl_LifeCycles.GamingDate,	
	'Progress' AS OperationName, 
	vt.FName AS ValueTypeName,
	den.FDescription AS Denomination,
	m.DenoID,
	NULL AS CashInbound,
 	m.FromQuantity,
	m.ToQuantity,
	GeneralPurpose.fn_UTCToLocal(1,m.ModDate) AS ModDate,
	USOWN.Lastname + ' ' + USOWN.Firstname AS UserName,
	OWNSites.ComputerName
FROM FloorActivity.tbl_ProgressModifications m
	INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = m.DenoID
    INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID	
    INNER JOIN Accounting.tbl_Progress p ON p.DenoID = m.denoID AND p.LifeCycleID = m.LifeCycleID AND p.StateTime = m.StateTime
    INNER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = p.LifeCycleID
    INNER JOIN CasinoLayout.Stocks sS ON Accounting.tbl_LifeCycles.StockID = sS.StockID
	INNER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = m.UserAccessID
	INNER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
	INNER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
UNION ALL
SELECT  'Modified Conteggi' AS cosa,
	con.ConteggioID AS TransactionID,
	ss.Tag, 
	ss.StockID,
	ss.[StockTypeID],
	0 AS LifeCycleid, 
	con.GamingDate,	
	'Conteggio ' + sS.Tag AS OperationName, 
	vt.FName AS ValueTypeName,
	den.FDescription AS Denomination,
	m.DenoID,
	NULL AS CashInbound,
 	m.FromQuantity,
	m.ToQuantity,
	GeneralPurpose.fn_UTCToLocal(1,cm.ModDate) AS ModDate,
	USOWN.Lastname + ' ' + USOWN.Firstname AS UserName,
	OWNSites.ComputerName
FROM [FloorActivity].[tbl_ConteggioValuesModifications] m
	INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = m.DenoID
    INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID	
	INNER JOIN [FloorActivity].[tbl_ConteggiModifications] cm ON cm.ModID = m.ModID
	INNER JOIN Accounting.tbl_Conteggi con ON con.ConteggioID = cm.ConteggioID
    INNER JOIN CasinoLayout.Stocks sS ON sS.StockID = m.StockID
	INNER JOIN FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = cm.UserAccessID
	INNER JOIN CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID 
	INNER JOIN CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID 
GO
