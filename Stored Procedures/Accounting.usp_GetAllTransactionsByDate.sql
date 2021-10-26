SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_GetAllTransactionsByDate]
@OpTypeID int,
@GamingDate smalldatetime,
@StockTypeID int,
@LFIsTheSource int
AS
	--if we do not specify a StockID check the StockTypeID
	if (@StockTypeID is null or @StockTypeID not in (select StockTypeID from CasinoLayout.StockTypes))
	begin
		raiserror('Must specify a valid StockTypeID',16,-1)
		return (1)
	end
	if (@GamingDate is null)
	begin
		--get current gaming date for the specified stock type
		set @GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				@StockTypeID)
		print 'Gaming date from user function is dbo.GetGamingLocalDate '+ convert(nvarchar,@GamingDate,113)
	end
	
	if (@OpTypeID is null) or (@OpTypeID not in (select OpTypeID from CasinoLayout.OperationTypes))
	begin
		raiserror('Must specify a valid Operation type ID',16,-1)
		return (1)
	end
if @LFIsTheSource is null 
set @LFIsTheSource = 2
if @OpTypeID = 2 --cambio
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
			TotalForSource, 
			TotalForDest
		 from Accounting.vw_AllTransactions
			where OpTypeID = @OpTypeID 
			and CashInbound = 1
			and SourceGamingDate = @GamingDate
			and SourceStockTypeID = @StockTypeID
	else if @LFIsTheSource = 1 --destination
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions
			where OpTypeID = @OpTypeID 
			and CashInbound = 0
			and DestGamingDate = @GamingDate
			and DestStockTypeID = @StockTypeID
	else if @LFIsTheSource = 2 --both source and destination
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions
			where OpTypeID = @OpTypeID 
			and ((SourceStockTypeID = @StockTypeID and SourceGamingDate = @GamingDate) or (DestStockTypeID = @StockTypeID and DestGamingDate = @GamingDate))
			and CashInbound = 1
	else
	begin
		raiserror('Must specify 0,1 or 2 as source,destination or both',16,-1)
		return (1)
	end
end		
else
begin
	if @LFIsTheSource = 0 --source
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions
			where OpTypeID = @OpTypeID 
			and SourceGamingDate = @GamingDate
			and SourceStockTypeID = @StockTypeID
	else if @LFIsTheSource = 1 --destination
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions
			where OpTypeID = @OpTypeID 
			and DestGamingDate = @GamingDate
			and DestStockTypeID = @StockTypeID
	else if @LFIsTheSource = 2 --both source and destination
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions
			where OpTypeID = @OpTypeID 
			and ((SourceStockTypeID = @StockTypeID and SourceGamingDate = @GamingDate) or (DestStockTypeID = @StockTypeID and DestGamingDate = @GamingDate))
	else
	begin
		raiserror('Must specify 0,1 or 2 as source,destination or both',16,-1)
		return (1)
	end
end
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllTransactionsByDate] TO [SolaLetturaNoDanni]
GO
