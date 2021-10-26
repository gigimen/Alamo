SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_GetCasseDaRipristinare] 
AS

SELECT OpTypeID, 
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
			IsSourceToday,
			IsSourceStockOpen,
			TotalEURForSource, 
			TotalCHFForSource, 
			TotalEURForDest, 
			TotalCHFForDest,
			r.IntRate			AS EuroRate
		from [Accounting].[vw_AllTransactionsEx] t
	    INNER JOIN CasinoLayout.Stocks SourceStock 	ON SourceStock.StockID = t.SourceStockID
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
		where t.OpTypeID = 6 --consegne
			AND t.SourceStockTypeID IN (4,7) --casse e cassa centrale
			-- transaction is pending if DestLifeCycleID is null
			and  t.DestLifeCycleID is null
			AND SourceStock.TillGamingDate IS NULL

GO
