SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_GetAllTransactionsByDateEx]
@OpTypeID INT,
@GamingDate SMALLDATETIME,
@StockTypeID INT,
@LFIsTheSource INT
AS
	--if we do not specify a StockID check the StockTypeID
	if (@StockTypeID is null or @StockTypeID not in (select StockTypeID from CasinoLayout.StockTypes))
	begin
		raiserror('Must specify a valid StockTypeID',16,-1)
		RETURN (1)
	END
	if (@GamingDate is null)
	begin
		--get current gaming date for the specified stock type
		set @GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				@StockTypeID)
		PRINT 'Gaming date from user function is dbo.GetGamingLocalDate '+ CONVERT(NVARCHAR,@GamingDate,113)
	END
	
	if (@OpTypeID is null) or (@OpTypeID not in (select OpTypeID from CasinoLayout.OperationTypes))
	begin
		raiserror('Must specify a valid Operation type ID',16,-1)
		RETURN (1)
	END
if @LFIsTheSource is null 
set @LFIsTheSource = 2
IF @OpTypeID = 2 --cambio
begin
	if @LFIsTheSource = 0 --source
		--for cambio we return the Richiesta transactions
		--when specifying the source stocktype id
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
			r.IntRate AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			where OpTypeID = @OpTypeID 
			and CashInbound = 1
			and SourceGamingDate = @GamingDate
			and SourceStockTypeID = @StockTypeID
	ELSE IF @LFIsTheSource = 1 --destination
		--for cambio we are interested in Consegna transactions 
		--when specifying the destination stocktype id
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
			r.IntRate AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			where OpTypeID = @OpTypeID 
			and CashInbound = 0
			and DestGamingDate = @GamingDate
			and DestStockTypeID = @StockTypeID
	ELSE IF @LFIsTheSource = 2 --both source and destination
		--for cambio we are in Consegna transactions when specifying the source 
		--lifecycle id
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
			r.IntRate AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			where OpTypeID = @OpTypeID 
			and ((SourceStockTypeID = @StockTypeID and SourceGamingDate = @GamingDate) or (DestStockTypeID = @StockTypeID and DestGamingDate = @GamingDate))
			and CashInbound = 1
	ELSE
	BEGIN
		raiserror('Must specify 0,1 or 2 as source,destination or both',16,-1)
		RETURN (1)
	END
END		
ELSE
BEGIN
	IF @LFIsTheSource = 0 --source
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
			r.IntRate AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0

			where OpTypeID = @OpTypeID 
			and SourceGamingDate = @GamingDate
			and SourceStockTypeID = @StockTypeID
	ELSE IF @LFIsTheSource = 1 --destination
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
			r.IntRate AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
			WHERE OpTypeID = @OpTypeID 
			AND DestGamingDate = @GamingDate
			AND DestStockTypeID = @StockTypeID
	ELSE IF @LFIsTheSource = 2 --both source and destination
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
			r.IntRate AS EuroRate 
		from [Accounting].[vw_AllTransactionsEx] t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0

			WHERE OpTypeID = @OpTypeID 
			AND ((SourceStockTypeID = @StockTypeID AND SourceGamingDate = @GamingDate) OR (DestStockTypeID = @StockTypeID AND DestGamingDate = @GamingDate))
	ELSE
	BEGIN
		RAISERROR('Must specify 0,1 or 2 as source,destination or both',16,-1)
		RETURN (1)
	END
END
GO
