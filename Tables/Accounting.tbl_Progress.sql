CREATE TABLE [Accounting].[tbl_Progress]
(
[LifeCycleID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[StateTime] [datetime] NOT NULL CONSTRAINT [DF_LifeCycleProgress_StateTime] DEFAULT (getutcdate()),
[Quantity] [int] NOT NULL,
[UserAccessID] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [Accounting].[NoProgressForStockClose] ON [Accounting].[tbl_Progress] 
INSTEAD OF INSERT
AS
/*
--if the user is a croupier 
--the progress cannot be inserted if the stock is closed
declare @uaID int
select @uaID = UserAccessID from inserted
--check that the user is a Croupier
if exists (
	select UserAccessID from dbo.UserAccesses
	INNER JOIN dbo.UserGroup_User 
	ON dbo.UserAccesses.UserID = dbo.UserGroup_User.UserID 
	INNER JOIN dbo.UserGroups 
	ON dbo.UserGroup_User.UserGroupID = dbo.UserGroups.UserGroupID 
	where dbo.UserAccesses.UserAccessID = @uaID 
	and  dbo.UserGroups.FName = 'Croupiers')
begin
	declare @LifeCycleID int
	declare @StockID int
	declare @GamingDate datetime
	declare @gd varchar(32)
	declare @Tag varchar(32)
	select @LifeCycleID = LifeCycleID from inserted
	if @LifeCycleID is null or not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
	begin
		raiserror('%d is not a valid LifeCycleID',16,1,@LifeCycleID)
		return
	end
	select @GamingDate = GamingDate,@StockID = StockID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID
	--check the stock has been open
	if not exists 
		(
		select LifeCycleSnapshotID from dbo.LifeCycleSnapshots  
			WHERE   dbo.LifeCycleSnapshots.LifeCycleID = @LifeCycleID 
			and dbo.LifeCycleSnapshots.SnapshotTypeID in (select SnapshotTypeID from dbo.SnapshotTypes where FName = 'Apertura')
			AND dbo.LifeCycleSnapshots.LCSnapShotCancelID IS NULL
		)
	begin
		set @gd = convert(varchar(32),@GamingDate,105)
		select @Tag = Tag from Stocks where StockID = @StockID
		raiserror('%s has not been opened for the gaming date %s',16,1,@Tag,@gd)
		return
	end
	--check the stock is not closed
	if exists 
		(
		select LifeCycleSnapshotID from dbo.LifeCycleSnapshots  
			WHERE   dbo.LifeCycleSnapshots.LifeCycleID = @LifeCycleID 
			and dbo.LifeCycleSnapshots.SnapshotTypeID in (select SnapshotTypeID from dbo.SnapshotTypes where FName = 'Chiusura')
			AND dbo.LifeCycleSnapshots.LCSnapShotCancelID IS NULL
		)
	begin
		set @gd = convert(varchar(32),@GamingDate,105)
		select @Tag = Tag from Stocks where StockID = @StockID
		raiserror('%s is closed for the gaming date %s',16,1,@Tag,@gd)
		return
	end
	INSERT INTO dbo.LifeCycleProgress
	       SELECT 	LifeCycleID,
			DenoID,
			StateTime,
			Quantity,
			UserAccessID,
			ExchangeRate
	       FROM inserted
end
else
--all other user can insert the progress even if the stock is closed
--just check that is open
begin
	select @LifeCycleID = LifeCycleID from inserted
	if @LifeCycleID is null or not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
	begin
		raiserror('%d is not a valid LifeCycleID',16,1,@LifeCycleID)
		return
	end
	select @GamingDate = GamingDate,@StockID = StockID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID
	--check the stock has been open
	if not exists 
		(
		select LifeCycleSnapshotID from dbo.LifeCycleSnapshots  
			WHERE   dbo.LifeCycleSnapshots.LifeCycleID = @LifeCycleID 
			and dbo.LifeCycleSnapshots.SnapshotTypeID in (select SnapshotTypeID from dbo.SnapshotTypes where FName = 'Apertura')
			AND dbo.LifeCycleSnapshots.LCSnapShotCancelID IS NULL
		)
	begin
		set @gd = convert(varchar(32),@GamingDate,105)
		select @Tag = Tag from Stocks where StockID = @StockID
		raiserror('%s has not been opened for the gaming date %s',16,1,@Tag,@gd)
		return
	end
	INSERT INTO dbo.LifeCycleProgress
	       SELECT 	LifeCycleID,
			DenoID,
			StateTime,
			Quantity,
			UserAccessID,
			ExchangeRate
	       FROM inserted
end
*/
INSERT INTO Accounting.tbl_Progress
       SELECT 	LifeCycleID,
		DenoID,
		StateTime,
		Quantity,
		UserAccessID,
		ExchangeRate
       FROM inserted
GO
ALTER TABLE [Accounting].[tbl_Progress] ADD CONSTRAINT [PK_LifeCycleProgress] PRIMARY KEY CLUSTERED  ([LifeCycleID], [DenoID], [StateTime]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Progress] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleProgress_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [Accounting].[tbl_Progress] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleProgress_LifeCycles] FOREIGN KEY ([LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Accounting].[tbl_Progress] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleProgress_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
