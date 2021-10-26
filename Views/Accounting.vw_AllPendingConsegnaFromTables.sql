SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- View
CREATE VIEW [Accounting].[vw_AllPendingConsegnaFromTables]
WITH SCHEMABINDING
AS
SELECT t.OpTypeID, 
	opt.FName				AS OperationName, 
	t.TransactionID, 
	t.SourceTime				AS SourceTimeLoc,
	GeneralPurpose.fn_UTCToLocal(1,t.SourceTime) 	AS SourceTimeUTC, 
	SourceStock.Tag 			AS SourceTag, 
	SourceStock.StockID 			AS SourceStockID, 
	SourceStock.StockTypeID 		AS SourceStockTypeID, 
	t.SourceLifeCycleID,
	SourceLFID.GamingDate			AS SourceGamingDate, 
	t.SourceUserAccessID,
	t.DestTime				AS DestTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,t.DestTime) 	AS DestTimeLoc,
	DestStock.Tag				AS DestStockTag,
	DestLFID.GamingDate			AS DestGamingDate,
	t.DestStockID,
	t.DestStockTypeID,
	t.DestLifeCycleID,
	t.DestUserAccessID,
	t.TrCancelID,
	DESTUA.UserID 		AS DestUserID,
	DESTSITE.FName 		AS DestSiteName,
	DESTUA.SiteID		AS DestSiteID,
	DESTUA.ApplicationID 	AS DestAppID,
	v.CashInbound,
	CASE SourceLFID.GamingDate
		WHEN GeneralPurpose.fn_GetGamingLocalDate2(
				GETUTCDATE(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GETUTCDATE(),GETDATE()),
				SourceStock.StockTypeID) THEN 1
	ELSE 0
	END AS IsSourceToday,
	CASE WHEN SourceCH.LifeCycleSnapshotID IS NULL THEN 1
		ELSE 0
	END  AS IsSourceStockOpen,
 	SUM(v.Quantity * d.Denomination * v.ExchangeRate * SDENO.WeightInTotal ) 	AS TotalForSource, 
 	SUM(v.Quantity * d.Denomination * v.ExchangeRate * DDENO.WeightInTotal ) 	AS TotalForDest
FROM    Accounting.tbl_Transactions t
-- 	INNER JOIN dbo.UserAccesses 		SUAID 		ON SUAID.UserAccessID = t.SourceUserAccessID 
	 INNER JOIN CasinoLayout.OperationTypes 		opt		ON opt.OpTypeID = t.OpTypeID 
        INNER JOIN Accounting.tbl_LifeCycles 		SourceLFID	ON SourceLFID.LifeCycleID = t.SourceLifeCycleID 
        INNER JOIN CasinoLayout.Stocks 			SourceStock 	ON SourceStock.StockID = SourceLFID.StockID
        LEFT OUTER JOIN Accounting.tbl_LifeCycles 		DestLFID 	ON t.DestLifeCycleID = DestLFID.LifeCycleID
        LEFT OUTER JOIN CasinoLayout.Stocks 		DestStock 	ON t.DestStockID = DestStock.StockID
        LEFT OUTER JOIN Accounting.tbl_TransactionValues 	v		ON v.TransactionID = t.TransactionID
        LEFT OUTER JOIN CasinoLayout.tbl_Denominations 	d		ON d.DenoID = v.DenoID 
	LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes 		vt		ON d.ValueTypeID = vt.ValueTypeID 
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations SDENO ON SDENO.StockCompositionID = SourceLFID.StockCompositionID AND SDENO.DenoID = d.DenoID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations DDENO ON DDENO.StockCompositionID = DestLFID.StockCompositionID AND DDENO.DenoID = d.DenoID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses 	DESTUA   	ON DESTUA.UserAccessID = t.DestUserAccessID 
	LEFT OUTER JOIN CasinoLayout.Sites 		DESTSITE   	ON DESTSITE.SiteID = DESTUA.SiteID 
	LEFT OUTER JOIN Accounting.tbl_Snapshots	SourceCH	ON SourceCH.LifeCycleID = t.SourceLifeCycleID AND SourceCH.SnapshotTypeID = 3 /*Chiusura*/ AND SourceCH.LCSnapShotCancelID IS NULL
--	LEFT OUTER JOIN dbo.LifeCycleSnapshots	DestCH		ON DestCH.LifeCycleID = t.DestLifeCycleID and DestCH.SnapshotTypeID = 3 --Chiusura
WHERE   (t.TrCancelID IS NULL)
	AND t.OpTypeID = 6 --only Consegna operations
	-- transaction is pending if DestLifeCycleID is null
	AND  t.DestLifeCycleID IS NULL
	AND 
	(
	   --all Stocks that this stock can be a receiver of their transactions
	   SourceStock.StockTypeID IN 
	   ( 
		SELECT SourceStockTypeID FROM CasinoLayout.TransactionFlows WHERE 
			DestStockTypeID = 2 --to main stock
			AND OpTypeID = 6 --Consegna
	   )
	OR --all Stocks that this stock is the receiver of their transactions
		t.DestStockID = 31 --main stock
	OR --all Stocks that this stocktype is the receiver of their transactions
		t.DestStockTypeID = 2 --main stock stock type
	)
	AND SourceStock.StockTypeID IN( 1,3) --source stock of type tavoli,SMT
	AND SourceStock.TillGamingDate IS NULL
GROUP BY
	t.OpTypeID, 
	opt.FName, 
	t.TransactionID, 
	t.SourceTime, 
	SourceStock.Tag, 
	SourceStock.StockID, 
	SourceStock.StockTypeID, 
	t.SourceLifeCycleID,
	SourceLFID.GamingDate, 
	t.SourceUserAccessID,
	t.SourceLifeCycleID,
	t.DestTime,
	DestStock.Tag,
	DestLFID.GamingDate,
	t.DestStockID,
	t.DestStockTypeID,
	t.DestLifeCycleID,
	t.DestUserAccessID,
	t.TrCancelID,
	DESTUA.UserID 		,
	DESTSITE.FName 		,
	DESTUA.SiteID		,
	DESTUA.ApplicationID 	,
	v.CashInbound,
	SourceCH.LifeCycleSnapshotID
GO
