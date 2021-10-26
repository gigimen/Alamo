SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_GetAllTransactionsFromStockTypeEx] 
@OpTypeID INT,
@SourceStockTypeID INT,
@gaming DATETIME,
@pending INT
AS


if not exists (SELECT OpTypeID from CasinoLayout.OperationTypes where OpTypeID = @OpTypeID)
begin
	raiserror('Invalid Operation type ID (%d)',16,1,@OpTypeID)
	RETURN
END
if not exists (select StockTypeID from CasinoLayout.StockTypes where StockTypeId = @SourceStockTypeID)
begin
	raiserror('Invalid StockType ID (%d)',16,1,@SourceStockTypeID)
	RETURN
END
if @pending is null
	set @pending = 0
if @gaming is null
begin
	if @pending <> 0
	begin
		select  OpTypeID, 
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
			TRCancelID,
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.DestGamingDate AND r.CurrencyID = 0
			
			where OpTypeID = @OpTypeID 
			-- transaction is pending if DestLifeCycleID is null
			and DestLifeCycleID is null
			and DestStockTypeID in 
			( 
				select DestStockTypeID from CasinoLayout.TransactionFlows where 
					SourceStockTypeID = @SourceStockTypeID
					and OpTypeID = @OpTypeID
			)
	end
	ELSE
	BEGIN
		SELECT  OpTypeID, 
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
			TRCancelID,
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.DestGamingDate AND r.CurrencyID = 0
			
			WHERE OpTypeID = @OpTypeID 
			-- transaction is not pending if DestLifeCycleID is not null
			AND  DestLifeCycleID IS NOT NULL
			AND DestStockTypeID IN 
			( 
				SELECT DestStockTypeID FROM CasinoLayout.TransactionFlows WHERE 
					SourceStockTypeID = @SourceStockTypeID
					AND OpTypeID = @OpTypeID
			)
	END
END
BEGIN
	IF @pending <> 0
	BEGIN
		--in such a case gaming date referes to source lifecycle
		SELECT  OpTypeID, 
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
			TRCancelID,
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			WHERE OpTypeID = @OpTypeID 
			-- transaction is pending if DestLifeCycleID is null
			AND DestLifeCycleID IS NULL
			AND DestStockTypeID IN 
			( 
				SELECT DestStockTypeID FROM CasinoLayout.TransactionFlows WHERE 
					SourceStockTypeID = @SourceStockTypeID
					AND OpTypeID = @OpTypeID
			)
			AND SourceGamingDate = @gaming
	END
	BEGIN
		SELECT  OpTypeID, 
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
			TRCancelID,
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.DestGamingDate AND r.CurrencyID = 0
			WHERE OpTypeID = @OpTypeID 
			-- transaction is not pending if DestLifeCycleID is not null
			AND  DestLifeCycleID IS NOT NULL
			AND DestStockTypeID IN 
			( 
				SELECT DestStockTypeID FROM CasinoLayout.TransactionFlows WHERE 
					SourceStockTypeID = @SourceStockTypeID
					AND OpTypeID = @OpTypeID
			)
			AND DestGamingDate = @gaming
	END
END

GO
