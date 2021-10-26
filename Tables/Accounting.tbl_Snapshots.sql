CREATE TABLE [Accounting].[tbl_Snapshots]
(
[LifeCycleSnapshotID] [int] NOT NULL IDENTITY(1, 1),
[LifeCycleID] [int] NOT NULL,
[UserAccessID] [int] NOT NULL,
[SnapshotTypeID] [int] NOT NULL,
[SnapshotTime] [datetime] NOT NULL,
[LCSnapShotCancelID] [int] NULL,
[SnapshotTimeLoc] [datetime] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Accounting].[CheckForDuplicatedOnInsert] ON [Accounting].[tbl_Snapshots] 
INSTEAD OF INSERT
AS
declare @SSTypeID int
declare @LifeCycleID int
declare @UserAccessID int
declare @stockID int
declare @GamingDate datetime
declare @gd varchar(32)
declare @tag varchar(32)

if (SELECT count(*) FROM inserted) > 1
begin
	raiserror('Snapshots must be created one by one',16,1,@LifeCycleID)
	return
end

SELECT 	@SSTypeID = SnapshotTypeID,
	@LifeCycleID = LifeCycleID,
	@UserAccessID = UserAccessID  
FROM inserted

if @LifeCycleID is null or not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
begin
	raiserror('%d is not a valid lifecycleid',16,1,@LifeCycleID)
	ROLLBACK TRANSACTION
	return
end
select 	@GamingDate = GamingDate,
	@stockID = st.StockID,
 	@gd = convert(varchar(32),GamingDate,105),
	@tag = st.Tag
from Accounting.tbl_LifeCycles 
inner join CasinoLayout.Stocks st on st.StockID = Accounting.tbl_LifeCycles.StockID
where Accounting.tbl_LifeCycles.LifeCycleID = @LifeCycleID

--print 'SnapshotTypeID ' + cast(@id as varchar(29))
--IF  WE INSERT AN APERTURA/CHIUSURA LET'S MAKE SURE THAT THERE 
--IS NOT AN APERTURA/CHIUSURA ALREADY FOR THAT STOCK FOR THAT GAMING DAY
if @SSTypeID in (1,3) --Apertura or chiusura
begin
--	declare @opType varchar(32)
	--select @opType = FName from SnapshotTypes where SnapshotTypeID = @SSTypeID
	--print 'LifeCycleID (' + cast(@LifeCycleID as varchar(29)) + ') StockID (' + cast(@StockID as varchar(29)) +')'
	--print 'Gaming date :' + @gd
	if exists 
		(
		select LifeCycleSnapshotID from Accounting.tbl_Snapshots 
		inner join Accounting.tbl_LifeCycles 
		on Accounting.tbl_Snapshots.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
		where  
		--for the same stock and gaming date
		Accounting.tbl_LifeCycles.StockID = @StockID
		and Accounting.tbl_LifeCycles.GamingDate = @GamingDate
		--of type apertura
		and Accounting.tbl_Snapshots.SnapshotTypeID = @SSTypeID
		--that is not canceled
		AND Accounting.tbl_Snapshots.LCSnapShotCancelID is null
		)
	begin
		if @SSTypeID = 1 --apertura
			raiserror('%s is already open for the gaming date %s',16,1,@tag,@gd)
		else
			raiserror('%s is already closed for the gaming date %s',16,1,@tag,@gd)
		ROLLBACK TRANSACTION
		return
	end
end

--in all case except apertura
--LET'S MAKE SURE THAT THERE IS AN APERTURA SNAPSHOT
if @SSTypeID <> 1 --apertura
begin
	--check the stock has been open
	if not exists 
		(
		select LifeCycleSnapshotID from Accounting.tbl_Snapshots  
			WHERE LifeCycleID = @LifeCycleID 
			and SnapshotTypeID  = 1
			AND LCSnapShotCancelID IS NULL
		)
	begin
		raiserror('%s has not been opened for the gaming date %s',16,1,@tag,@gd)
		ROLLBACK TRANSACTION
		return
	end
end

--in all cases except for conteggio uscita di incasso
--CHECK THAT THE STOCK IS NOT CLOSED
if not (@stockID = 47 and @SSTypeID = 6)
begin
	if exists 
		(
		select LifeCycleSnapshotID from Accounting.tbl_Snapshots  
			WHERE   Accounting.tbl_Snapshots.LifeCycleID = @LifeCycleID 
			and Accounting.tbl_Snapshots.SnapshotTypeID =  3 --Chiusura
			AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
		)
	begin
		raiserror('%s is closed for the gaming date %s',16,1,@tag,@gd)
		ROLLBACK TRANSACTION
		return
	end
end


-- IN CASE OF CHIUSURA
--CHECK THAT THE STOCK HAS NO PENDING TRANSACTIONS except consegna per ripristino and ripristinos
--(i.e. transactions that have been locked but not acceptedt yet)
--IF THE PENDING TRANSACTION HAS BEEN LOCKED RAISE AN EXCEPTION
--OTHERWISE JUST DELETE THE PENDING TRANSACTIONS
if @SSTypeID = 3 --chiusura
BEGIN
/*this feature disabled the 14.2.2015 it creates a disaster 
	consegna is created but the stock is not closed!!!
	declare @pending int
	select @pending = count(*) from Accounting.Transactions 
		where SourceLifeCycleID = @LifeCycleID
		AND Accounting.Transactions.TrCancelID is null --is not canceled
		AND Accounting.Transactions.DestUserAccessID is not null --is locked
		AND Accounting.Transactions.DestLifeCycleID is null --but has not been accepted yet
		AND Accounting.Transactions.OpTypeID not in (5,6) --'ConsegnaPerRipristino' or FName = 'Ripristino'
	if @pending > 0
	begin
		if @pending = 1
			RAISERROR('Cannot close stock %s because 1 transaction is still pending',16,1,@tag)
		else
			RAISERROR('Cannot close stock %s because %d transactions are still pending',16,1,@tag,@pending)
		ROLLBACK TRANSACTION
		RETURN
	end
	*/
	--we can close but we have to cancel all not accepted transactions
	declare @ret int
	set @ret = CURSOR_STATUS ('global','not_accept_trans_cursor')
	--print 'CURSOR_STATUS returned ' + cast(@ret as varchar) 
	if @ret > -3
	begin
		--print 'deallocting not_accept_trans_cursor'
		DEALLOCATE not_accept_trans_cursor
	end
	DECLARE not_accept_trans_cursor CURSOR
	   FOR
		select TransactionID from Accounting.tbl_Transactions
		where SourceLifeCycleID = @LifeCycleID
			AND TrCancelID is null --is not canceled
			--delete also locked transactions
			--AND Accounting.Transactions.DestUserAccessID is null --is not locked
			AND DestLifeCycleID is null --and has not been accepted yet
			AND OpTypeID not in (5,6,18) --'ConsegnaPerRipristino' or FName = 'Ripristino' or dotazione gettoni
	OPEN not_accept_trans_cursor
	DECLARE @transID int
	FETCH NEXT FROM not_accept_trans_cursor INTO @transID
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
	   EXECUTE Accounting.usp_DeleteTransaction @transID,@UserAccessID
	   FETCH NEXT FROM not_accept_trans_cursor INTO @transID
	END
	if CURSOR_STATUS ('global','not_accept_trans_cursor') > -3
		DEALLOCATE not_accept_trans_cursor
END


--EVERYTHING OK SO WE CAN INSERT THE SNAPSHOT
INSERT INTO Accounting.tbl_Snapshots
       SELECT LifeCycleID,UserAccessID,SnapshotTypeID,SnapshotTime,LCSnapShotCancelID,SnapshotTimeLoc
       FROM inserted
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [Accounting].[CheckIfTransactionsOnDelete] ON [Accounting].[tbl_Snapshots] 
INSTEAD OF DELETE
AS
declare @SnapshotTypeID int
declare @SnapShotID int
declare @lfid int
SELECT 	@SnapshotTypeID = SnapshotTypeID,
       	@SnapShotID = LifeCycleSnapshotID,
	@lfid = LifeCycleID  
	FROM deleted
--print 'SnapshotTypeID ' + cast(@SnapshotTypeID as varchar(29))
if @SnapshotTypeID  = 1 --'Apertura')
begin
	--print 'LifeCycleID ' + cast(@id as varchar(29))
	if exists (select TransactionID from Accounting.vw_AllTransactions 
		where 
		(
		SourceLifeCycleID = @lfid 
		or (DestLifeCycleID = @lfid and Accounting.vw_AllTransactions.OpTypeID <> 5)--'Ripristino') 
		) 
		AND Accounting.vw_AllTransactions.TrCancelID is null
		)
	begin
		raiserror('Snapshot %d being cancelled but transactions exist',16,1,@SnapShotID)
		ROLLBACK TRANSACTION
		return
	end
	else if @SnapshotTypeID = 1-- 'Apertura')
		and exists 
		(
		select LifeCycleSnapshotID from Accounting.tbl_Snapshots 
		where LifeCycleID = @lfid 
		and LifeCycleSnapshotID <> @SnapShotID
		AND Accounting.tbl_Snapshots.LCSnapShotCancelID is null
		)
	begin
		raiserror('Apertura Snapshot %d being cancelled but other Snapshots exist',16,1,@SnapShotID)
		ROLLBACK TRANSACTION
		return
	end
	else if exists 
		(
		select LifeCycleID from Accounting.tbl_Progress 
		where LifeCycleID = @lfid 
		)
	begin
		raiserror('Snapshot %d being cancelled but Progress exist',16,1,@SnapShotID)
		ROLLBACK TRANSACTION
		return
	end
END

delete from Accounting.tbl_Snapshots
where LifeCycleSnapshotID = @SnapShotID
GO
ALTER TABLE [Accounting].[tbl_Snapshots] ADD CONSTRAINT [PK_LifeCycleSnapshot] PRIMARY KEY CLUSTERED  ([LifeCycleSnapshotID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LifeCycleSnapshots_bySnapshotType] ON [Accounting].[tbl_Snapshots] ([LifeCycleID], [SnapshotTypeID], [LCSnapShotCancelID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LifeCycleSnapshots_OnSnapshotTypeID] ON [Accounting].[tbl_Snapshots] ([SnapshotTypeID], [LCSnapShotCancelID]) INCLUDE ([LifeCycleID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Snapshots] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleSnapshot_LifeCycles] FOREIGN KEY ([LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Accounting].[tbl_Snapshots] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleSnapshot_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [Accounting].[tbl_Snapshots] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleSnapshots_CancelActions] FOREIGN KEY ([LCSnapShotCancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [Accounting].[tbl_Snapshots] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleSnapshots_SnapshotTypes] FOREIGN KEY ([SnapshotTypeID]) REFERENCES [CasinoLayout].[SnapshotTypes] ([SnapshotTypeID])
GO
