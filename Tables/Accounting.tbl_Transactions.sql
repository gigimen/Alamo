CREATE TABLE [Accounting].[tbl_Transactions]
(
[TransactionID] [int] NOT NULL IDENTITY(1, 1),
[OpTypeID] [int] NOT NULL,
[SourceLifeCycleID] [int] NOT NULL,
[DestStockID] [int] NULL,
[DestLifeCycleID] [int] NULL,
[SourceTime] [datetime] NOT NULL,
[DestStockTypeID] [int] NULL,
[SourceUserAccessID] [int] NOT NULL,
[DestUserAccessID] [int] NULL,
[TrCancelID] [int] NULL,
[DestTime] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Accounting].[CheckForStockClose] ON [Accounting].[tbl_Transactions] 
INSTEAD OF INSERT
AS
declare @LifeCycleID int
declare @stockID int
declare @GamingDate datetime
declare @gd varchar(32)
declare @tag varchar(32)
select @LifeCycleID = SourceLifeCycleID from inserted
if @LifeCycleID is null or not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
begin
	raiserror('%d is not a valid lifecycleid',16,1,@LifeCycleID)
	ROLLBACK TRANSACTION
	return
end
select @GamingDate = GamingDate,@stockID = StockID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID
--check the stock has been open
if not exists 
	(
	select LifeCycleSnapshotID from Accounting.tbl_Snapshots  
		WHERE   Accounting.tbl_Snapshots.LifeCycleID = @LifeCycleID 
		and Accounting.tbl_Snapshots.SnapshotTypeID in (select SnapshotTypeID from CasinoLayout.SnapshotTypes where FName = 'Apertura')
		AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
	)
begin
	set @gd = convert(varchar(32),@GamingDate,105)
	select @tag = Tag from CasinoLayout.Stocks where StockID = @StockID
	raiserror('%s has not been opened for the gaming date %s',16,1,@tag,@gd)
	ROLLBACK TRANSACTION
	return
end

--check the stock is not closed
if exists 
	(
	select LifeCycleSnapshotID from Accounting.tbl_Snapshots  
		WHERE   Accounting.tbl_Snapshots.LifeCycleID = @LifeCycleID 
		and Accounting.tbl_Snapshots.SnapshotTypeID in (select SnapshotTypeID from CasinoLayout.SnapshotTypes where FName = 'Chiusura')
		AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
	)
begin
	set @gd = convert(varchar(32),@GamingDate,105)
	select @tag = Tag from CasinoLayout.Stocks where StockID = @StockID
	raiserror('%s is closed for the gaming date %s',16,1,@tag,@gd)
	ROLLBACK TRANSACTION
	return
end

INSERT INTO Accounting.tbl_Transactions
       SELECT 	
		OpTypeID,
	    SourceLifeCycleID,
		DestStockID,
		DestLifeCycleID,
		SourceTime,
		DestStockTypeID,
		SourceUserAccessID,
		DestUserAccessID,
		TrCancelID,
		DestTime
       FROM inserted

GO
DISABLE TRIGGER [Accounting].[CheckForStockClose] ON [Accounting].[tbl_Transactions]
GO
ALTER TABLE [Accounting].[tbl_Transactions] ADD CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED  ([TransactionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Transactions_DestLifeCycleID] ON [Accounting].[tbl_Transactions] ([DestLifeCycleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Transactions_SourceLifeCycleID] ON [Accounting].[tbl_Transactions] ([SourceLifeCycleID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Transactions] WITH NOCHECK ADD CONSTRAINT [FK_Transactions_DestLifeCycles] FOREIGN KEY ([DestLifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Accounting].[tbl_Transactions] WITH NOCHECK ADD CONSTRAINT [FK_Transactions_DestUserAccesses] FOREIGN KEY ([DestUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [Accounting].[tbl_Transactions] ADD CONSTRAINT [FK_Transactions_OperationTypes] FOREIGN KEY ([OpTypeID]) REFERENCES [CasinoLayout].[OperationTypes] ([OpTypeID])
GO
ALTER TABLE [Accounting].[tbl_Transactions] WITH NOCHECK ADD CONSTRAINT [FK_Transactions_SourceLifeCycles] FOREIGN KEY ([SourceLifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Accounting].[tbl_Transactions] WITH NOCHECK ADD CONSTRAINT [FK_Transactions_SourceUserAccesses] FOREIGN KEY ([SourceUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [Accounting].[tbl_Transactions] WITH NOCHECK ADD CONSTRAINT [FK_Transactions_Stocks] FOREIGN KEY ([DestStockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
ALTER TABLE [Accounting].[tbl_Transactions] WITH NOCHECK ADD CONSTRAINT [FK_Transactions_StockTypes] FOREIGN KEY ([DestStockTypeID]) REFERENCES [CasinoLayout].[StockTypes] ([StockTypeID])
GO
ALTER TABLE [Accounting].[tbl_Transactions] WITH NOCHECK ADD CONSTRAINT [FK_Transactions_TransactionCanceled] FOREIGN KEY ([TrCancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
