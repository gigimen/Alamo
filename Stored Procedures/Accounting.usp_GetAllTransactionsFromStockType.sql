SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_GetAllTransactionsFromStockType] 
@OpTypeID int,
@SourceStockTypeID int,
@gaming datetime,
@pending int
AS
if not exists (SELECT OpTypeID from CasinoLayout.OperationTypes where OpTypeID = @OpTypeID)
begin
	raiserror('Invalid Operation type ID (%d)',16,1,@OpTypeID)
	return
end
if not exists (select StockTypeID from CasinoLayout.StockTypes where StockTypeId = @SourceStockTypeID)
begin
	raiserror('Invalid StockType ID (%d)',16,1,@SourceStockTypeID)
	return
end
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions 
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
	else
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions 
			where OpTypeID = @OpTypeID 
			-- transaction is not pending if DestLifeCycleID is not null
			and  DestLifeCycleID is not null
			and DestStockTypeID in 
			( 
				select DestStockTypeID from CasinoLayout.TransactionFlows where 
					SourceStockTypeID = @SourceStockTypeID
					and OpTypeID = @OpTypeID
			)
	end
end
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
			TRCancelID,
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
			and DestLifeCycleID is null
			and DestStockTypeID in 
			( 
				select DestStockTypeID from CasinoLayout.TransactionFlows where 
					SourceStockTypeID = @SourceStockTypeID
					and OpTypeID = @OpTypeID
			)
			and SourceGamingDate = @gaming
	end
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
			TotalForSource, 
			TotalForDest
		from Accounting.vw_AllTransactions 
			where OpTypeID = @OpTypeID 
			-- transaction is not pending if DestLifeCycleID is not null
			and  DestLifeCycleID is not null
			and DestStockTypeID in 
			( 
				select DestStockTypeID from CasinoLayout.TransactionFlows where 
					SourceStockTypeID = @SourceStockTypeID
					and OpTypeID = @OpTypeID
			)
			and DestGamingDate = @gaming
	end
end
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllTransactionsFromStockType] TO [SolaLetturaNoDanni]
GO
