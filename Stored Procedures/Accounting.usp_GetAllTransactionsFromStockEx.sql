SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_GetAllTransactionsFromStockEx] 
@OpTypeID INT,
@SourceStockID INT,
@gaming DATETIME,
@pending INT
AS


	if not exists (select OpTypeID from CasinoLayout.OperationTypes where OpTypeID = @OpTypeID)
	begin
		raiserror('Invalid Operation type ID (%d)',16,1,@OpTypeID)
		RETURN
	END
	declare @SourceStockTypeID int
	select @SourceStockTypeID = StockTypeID from CasinoLayout.Stocks where StockID = @SourceStockID
	if @SourceStockTypeID is null
	begin
		raiserror('Invalid Stock ID (%d)',16,1,@SourceStockID)
		RETURN
	END


if @pending is null
	set @pending = 0
IF @gaming IS NULL
	if @pending <> 0
		select OpTypeID, 
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			where OpTypeID = @OpTypeID
			-- transaction is pending if DestLifeCycleID is null
			and  DestLifeCycleID is null
			and  SourceStockID = @SourceStockID
	ELSE
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			WHERE OpTypeID = @OpTypeID 
			-- transaction is not pending if DestLifeCycleID is not null
			AND  DestLifeCycleID IS NOT NULL
			AND  SourceStockID = @SourceStockID
ELSE
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			WHERE OpTypeID = @OpTypeID
			-- transaction is pending if DestLifeCycleID is null
			AND  DestLifeCycleID IS NULL
			AND  SourceStockID = @SourceStockID
			AND  SourceGamingDate = @gaming
	END
	ELSE
	BEGIN
		--look for the dest LifeCycleID
		DECLARE @sourcelfid INT
		SELECT @sourcelfid = LifeCycleID FROM Accounting.tbl_LifeCycles WHERE StockID = @SourceStockID AND GamingDate = @gaming
		IF @sourcelfid IS NULL
		BEGIN
			RAISERROR('Stock %d has no lifecycle for the specified gaming date',16,1)
			RETURN (1)
		END
	
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
			r.IntRate  AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
		WHERE OpTypeID = @OpTypeID 
			-- transaction is not pending if DestLifeCycleID is not null
			AND  DestLifeCycleID IS NOT NULL
			AND  SourceLifeCycleID  = @sourcelfid
	END
END
GO
