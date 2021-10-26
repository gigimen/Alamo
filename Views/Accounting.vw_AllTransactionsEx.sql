SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllTransactionsEx]
WITH SCHEMABINDING
AS

select 
	OpTypeID, 
	OperationName, 
	TransactionID, 
	SourceTimeUTC,
	SourceTimeLoc, 
	SourceTag, 
	SourceStockID, 
	SourceStockTypeID, 
	SourceLifeCycleID,
	SourceGamingDate, 
	SourceUserAccessID,
	DestTimeUTC,
	DestTimeLoc,
	DestStockTag,
	DestGamingDate,
	DestStockID,
	DestStockTypeID,
	DestLifeCycleID,
	DestUserAccessID,
	TrCancelID,
	DestUserID,
	DestSiteName,
	DestSiteID,
	DestAppID,
	CashInbound,
	IsSourceStockOpen,
	IsSourceToday,
	(case when optypeID = 18 and Cashinbound = 0 then -1 else 1 end) * TotalEURForSource	AS  TotalEURForSource	,   
	(case when optypeID = 18 and Cashinbound = 0 then -1 else 1 end) * TotalCHFForSource	AS  TotalCHFForSource	,  
 	(case when optypeID = 18 and Cashinbound = 0 then -1 else 1 end) * TotalEURForDest		AS  TotalEURForDest		,   
	(case when optypeID = 18 and Cashinbound = 0 then -1 else 1 end) * TotalCHFForDest  	AS  TotalCHFForDest  

from
(
SELECT  
	opt.OpTypeID, 
	opt.FName				AS OperationName, 
	t.TransactionID, 
	t.SourceTime				AS SourceTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,t.SourceTime) 	AS SourceTimeLoc, 
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
	ISNULL(SUM(CASE WHEN vt.CurrencyID = 0 THEN v.Quantity * d.Denomination * SDENO.WeightInTotal ELSE 0 END),0)  AS TotalEURForSource  ,   
	ISNULL(SUM(CASE WHEN vt.CurrencyID <> 0 THEN v.Quantity * d.Denomination * v.ExchangeRate * SDENO.WeightInTotal ELSE 0 END),0) AS TotalCHFForSource,  
 	ISNULL(SUM(CASE WHEN vt.CurrencyID = 0 THEN v.Quantity * d.Denomination * DDENO.WeightInTotal ELSE 0 END),0)  AS TotalEURForDest  ,   
	ISNULL(SUM(CASE WHEN vt.CurrencyID <> 0 THEN v.Quantity * d.Denomination * v.ExchangeRate * DDENO.WeightInTotal ELSE 0 END),0) AS TotalCHFForDest  
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
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations SDENO ON SDENO.StockCompositionID = SourceLFID.StockCompositionID AND SDENO.DenoID = d.DenoID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations DDENO ON DDENO.StockCompositionID = DestLFID.StockCompositionID AND DDENO.DenoID = d.DenoID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses 	DESTUA   	ON DESTUA.UserAccessID = t.DestUserAccessID 
	LEFT OUTER JOIN CasinoLayout.Sites 		DESTSITE   	ON DESTSITE.SiteID = DESTUA.SiteID 
	LEFT OUTER JOIN Accounting.tbl_Snapshots	SourceCH	ON SourceCH.LifeCycleID = t.SourceLifeCycleID AND SourceCH.SnapshotTypeID = 3 /*Chiusura*/ AND SourceCH.LCSnapShotCancelID IS NULL
--	LEFT OUTER JOIN dbo.LifeCycleSnapshots	DestCH		ON DestCH.LifeCycleID = t.DestLifeCycleID and DestCH.SnapshotTypeID = 3 --Chiusura
WHERE   (t.TrCancelID IS NULL)
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
	) a
GO
