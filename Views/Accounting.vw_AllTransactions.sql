SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllTransactions]
WITH SCHEMABINDING
AS
SELECT  opt.OpTypeID, 
	opt.FName				AS OperationName, 
	t.TransactionID, 
	t.SourceTime				as SourceTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,t.SourceTime) 	as SourceTimeLoc, 
	SourceStock.Tag 			AS SourceTag, 
	SourceStock.StockID 			AS SourceStockID, 
	SourceStock.StockTypeID 		AS SourceStockTypeID, 
	t.SourceLifeCycleID,
	SourceLFID.GamingDate			AS SourceGamingDate, 
	t.SourceUserAccessID,
	t.DestTime				AS DestTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,t.DestTime) 	as DestTimeLoc,
	DestStock.Tag				AS DestStockTag,
	DestLFID.GamingDate			AS DestGamingDate,
	t.DestStockID,
	t.DestStockTypeID,
	t.DestLifeCycleID,
	t.DestUserAccessID,
	t.TrCancelID,
	DESTUA.UserID 		as DestUserID,
	DESTSITE.FName 		as DestSiteName,
	DESTUA.SiteID		as DestSiteID,
	DESTUA.ApplicationID 	as DestAppID,
	v.CashInbound,
	case SourceLFID.GamingDate
		when GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				SourceStock.StockTypeID) then 1
	else 0
	end as IsSourceToday,
	case when SourceCH.LifeCycleSnapshotID is null then 1
		else 0
	end  as IsSourceStockOpen,
 	SUM(IsNULL(v.Quantity * d.Denomination * v.ExchangeRate * SDENO.WeightInTotal,0) ) 	AS TotalForSource, 
 	SUM(IsNULL(v.Quantity * d.Denomination * v.ExchangeRate * DDENO.WeightInTotal,0) ) 	AS TotalForDest
FROM    Accounting.tbl_Transactions t
-- 	INNER JOIN dbo.UserAccesses 		SUAID 		ON SUAID.UserAccessID = t.SourceUserAccessID 
	 INNER JOIN CasinoLayout.OperationTypes 		opt		ON t.OpTypeID = opt.OpTypeID 
        INNER JOIN Accounting.tbl_LifeCycles 		SourceLFID	ON SourceLFID.LifeCycleID = t.SourceLifeCycleID 
        INNER JOIN CasinoLayout.Stocks 			SourceStock 	ON SourceStock.StockID = SourceLFID.StockID
        LEFT OUTER JOIN Accounting.tbl_LifeCycles 		DestLFID 	ON t.DestLifeCycleID = DestLFID.LifeCycleID
        LEFT OUTER JOIN CasinoLayout.Stocks 		DestStock 	ON t.DestStockID = DestStock.StockID
        LEFT OUTER JOIN Accounting.tbl_TransactionValues 	v		ON v.TransactionID = t.TransactionID
        LEFT OUTER JOIN CasinoLayout.tbl_Denominations 	d		ON d.DenoID = v.DenoID 
	LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes 		vt		ON d.ValueTypeID = vt.ValueTypeID 
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations SDENO ON SDENO.StockCompositionID = SourceLFID.StockCompositionID and SDENO.DenoID = d.DenoID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations DDENO ON DDENO.StockCompositionID = DestLFID.StockCompositionID and DDENO.DenoID = d.DenoID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses 	DESTUA   	ON DESTUA.UserAccessID = t.DestUserAccessID 
	LEFT OUTER JOIN CasinoLayout.Sites 		DESTSITE   	ON DESTSITE.SiteID = DESTUA.SiteID 
	LEFT OUTER JOIN Accounting.tbl_Snapshots	SourceCH	ON SourceCH.LifeCycleID = t.SourceLifeCycleID and SourceCH.SnapshotTypeID = 3 /*Chiusura*/ and SourceCH.LCSnapShotCancelID is null
--	LEFT OUTER JOIN dbo.LifeCycleSnapshots	DestCH		ON DestCH.LifeCycleID = t.DestLifeCycleID and DestCH.SnapshotTypeID = 3 --Chiusura
WHERE   (t.TrCancelID is null)
GROUP BY
	opt.OpTypeID, 
	opt.FName, 
	t.TransactionID, 
	t.SourceTime, 
	--t.SourceTime,
	SourceStock.Tag, 
	SourceStock.StockID, 
	SourceStock.StockTypeID, 
	t.SourceLifeCycleID,
	SourceLFID.GamingDate, 
	t.SourceUserAccessID,
	t.SourceLifeCycleID,
	t.DestTime,
	--t.DestTime,
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
