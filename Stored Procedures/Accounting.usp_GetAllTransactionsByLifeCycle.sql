SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_GetAllTransactionsByLifeCycle]
@OpTypeID int,
@LifeCycleID int,
@LFIsTheSource int
AS
	--if we do not specify a StockID check the StockTypeID
	if @LifeCycleID is null or not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
	begin
		raiserror('Must specify a valid LifeCycleID',16,-1)
		return (1)
	end
	if (@OpTypeID is null) or (@OpTypeID not in (select OpTypeID from CasinoLayout.OperationTypes))
	begin
		raiserror('Must specify a valid Operation type ID',16,-1)
		return (1)
	end
if @LFIsTheSource is null 
set @LFIsTheSource = 2
if @OpTypeID = 2 --'Cambio')
begin
	if @LFIsTheSource = 0 --source
		--for cambio we are in Consegna transactions when specifying the destination 
		--lifecycle id
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
			and CashInbound = 0 -- in uscita
			and SourceLifeCycleID = @LifeCycleID
	else if @LFIsTheSource = 1 --destination
		--for cambio we are interested in Richiesta transactions when specifying the source 
		--lifecycle id
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
			and CashInbound = 1 -- in ingresso
			and DestLifeCycleID = @LifeCycleID
	else if @LFIsTheSource = 2 --both source and destination
		--for cambio we are in Consegna transactions when specifying the destination 
		--lifecycle id
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
			and (SourceLifeCycleID = @LifeCycleID or DestLifeCycleID = @LifeCycleID)
			and CashInbound = 1 -- in uscita
	else
	begin
		raiserror('Must specify 0,1 or 2 as source,destination or both',16,-1)
		return (1)
	end
end
else
begin
	if @LFIsTheSource = 0	--source
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
			and SourceLifeCycleID = @LifeCycleID
	else if @LFIsTheSource = 1	--destination
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
			and DestLifeCycleID = @LifeCycleID
	else if @LFIsTheSource = 2	--both
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
			and (DestLifeCycleID = @LifeCycleID or SourceLifeCycleID = @LifeCycleID)
	else
	begin
		raiserror('Must specify 0,1 or 2 as source,destination or both',16,-1)
		return (1)
	end	
end
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllTransactionsByLifeCycle] TO [SolaLetturaNoDanni]
GO
