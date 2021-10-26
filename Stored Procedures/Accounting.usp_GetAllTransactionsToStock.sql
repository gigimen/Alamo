SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_GetAllTransactionsToStock] 
@OpTypeID int,
@DestStockID int,
@gaming datetime,
@pending int
AS
if not exists (select OpTypeID from CasinoLayout.OperationTypes where OpTypeID = @OpTypeID)
begin
	raiserror('Invalid Operation type ID (%d)',16,1,@OpTypeID)
	return
end
declare @DestStockTypeID int
select @DestStockTypeID = StockTypeID from CasinoLayout.Stocks where StockID = @DestStockID
if @DestStockTypeID is null
begin
	raiserror('Invalid Stock ID (%d)',16,1,@DestStockID)
	return
end
if @pending is null
	set @pending = 0
--print @DestStockTypeID
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
		from Accounting.vw_AllTransactions t
       INNER JOIN CasinoLayout.Stocks 			SourceStock 	ON SourceStock.StockID = t.SourceStockID
			where t.OpTypeID = @OpTypeID
			-- transaction is pending if DestLifeCycleID is null
			and  t.DestLifeCycleID is null
			and 
			(
			   --all Stocks that this stock can be a receiver of their transactions
			   t.SourceStockTypeID in 
			   ( 
				select SourceStockTypeID from CasinoLayout.TransactionFlows where 
					DestStockTypeID = @DestStockTypeID
					and OpTypeID = @OpTypeID
			   )
			or --all Stocks that this stock is the receiver of their transactions
				t.DestStockID = @DestStockID
			or --all Stocks that this stocktype is the receiver of their transactions
				t.DestStockTypeID = @DestStockTypeID
			)
			AND SourceStock.TillGamingDate IS NULL

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
		from Accounting.vw_AllTransactions t
      INNER JOIN CasinoLayout.Stocks 			SourceStock 	ON SourceStock.StockID = t.SourceStockID
			where OpTypeID = @OpTypeID 
			-- transaction is not pending if DestLifeCycleID is not null
			and  DestLifeCycleID is not null
			and 
			(
			   --all Stocks that this stock can be a receiver of their transactions
			   SourceStockTypeID in 
			   ( 
				select SourceStockTypeID from CasinoLayout.TransactionFlows where 
					DestStockTypeID = @DestStockTypeID
					and OpTypeID = @OpTypeID
			   )
			or --all Stocks that this stock is the receiver of their transactions
				DestStockID = @DestStockID
			or --all Stocks that this stocktype is the receiver of their transactions
				DestStockTypeID = @DestStockTypeID
			)
else
begin
	if @pending <> 0
	begin
		--in such a case gaming date referes to source lifecycle
		--look for the source LifeCycleID
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
		from Accounting.vw_AllTransactions t
      INNER JOIN CasinoLayout.Stocks 			SourceStock 	ON SourceStock.StockID = t.SourceStockID
			where OpTypeID = @OpTypeID
			-- transaction is pending if DestLifeCycleID is null
			and  DestLifeCycleID is null
			and 
			(
			   --all Stocks that this stock can be a receiver of their transactions
			   SourceStockTypeID in 
			   ( 
				select SourceStockTypeID from CasinoLayout.TransactionFlows where 
					DestStockTypeID = @DestStockTypeID
					and OpTypeID = @OpTypeID
			   )
			or --all Stocks that this stock is the receiver of their transactions
				DestStockID = @DestStockID
			or --all Stocks that this stocktype is the receiver of their transactions
				DestStockTypeID = @DestStockTypeID
			)
			and SourceGamingDate = @gaming
			AND SourceStock.TillGamingDate IS NULL
		
	end
	else
	begin
		--look for the dest LifeCycleID
		declare @destlfid int
		select @destlfid = LifeCycleID from Accounting.tbl_LifeCycles where StockID = @DestStockID and GamingDate = @gaming
		if @destlfid is null
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
			-- transaction is pending if DestLifeCycleID is null
			and  DestLifeCycleID  = @destlfid
	end
end
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllTransactionsToStock] TO [SolaLetturaNoDanni]
GO
