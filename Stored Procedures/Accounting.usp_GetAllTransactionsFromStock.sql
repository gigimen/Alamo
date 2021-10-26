SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_GetAllTransactionsFromStock] 
@OpTypeID int,
@SourceStockID int,
@gaming datetime,
@pending int
AS
if not exists (select OpTypeID from CasinoLayout.OperationTypes where OpTypeID = @OpTypeID)
begin
	raiserror('Invalid Operation type ID (%d)',16,1,@OpTypeID)
	return
end
declare @SourceStockTypeID int
select @SourceStockTypeID = StockTypeID from CasinoLayout.Stocks where StockID = @SourceStockID
if @SourceStockTypeID is null
begin
	raiserror('Invalid Stock ID (%d)',16,1,@SourceStockID)
	return
end
if @pending is null
	set @pending = 0
if @gaming is null
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions 
			where OpTypeID = @OpTypeID
			-- transaction is pending if DestLifeCycleID is null
			and  DestLifeCycleID is null
			and  SourceStockID = @SourceStockID
	else
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
			-- transaction is not pending if DestLifeCycleID is not null
			and  DestLifeCycleID is not null
			and  SourceStockID = @SourceStockID
else
begin
	if @pending <> 0
	begin
		--in such a case gaming date referes to source lifecycle
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
			-- transaction is pending if DestLifeCycleID is null
			and  DestLifeCycleID is null
			and  SourceStockID = @SourceStockID
			and  SourceGamingDate = @gaming
	end
	else
	begin
		--look for the dest LifeCycleID
		declare @sourcelfid int
		select @sourcelfid = LifeCycleID from Accounting.tbl_LifeCycles where StockID = @SourceStockID and GamingDate = @gaming
		if @sourcelfid is null
		begin
			raiserror('Stock %d has no lifecycle for the specified gaming date',16,1)
			return (1)
		end
	
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
			-- transaction is not pending if DestLifeCycleID is not null
			and  DestLifeCycleID is not null
			and  SourceLifeCycleID  = @sourcelfid
	end
end
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllTransactionsFromStock] TO [SolaLetturaNoDanni]
GO
