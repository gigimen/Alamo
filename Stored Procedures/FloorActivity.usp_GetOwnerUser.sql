SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE procedure [FloorActivity].[usp_GetOwnerUser] 
@LifeCycleID int,
@UserID int output,
@UserGroupID int output,
@LastName varchar(50) output,
@FirstName varchar(50) output
AS
--run some checks on input data
if not exists( select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
begin
	raiserror('Must specify a valid LifeCycleID',16,1)
	return(0)
end
--first check that some change owner snapshot exist
if exists ( select LifeCycleSnapshotID 
		from Accounting.tbl_Snapshots 
		where LifeCycleID = @LifeCycleID
		and SnapshotTypeID = 4 --CHANGEOWNER
	)
--then check that the last one is for the user
begin
	print 'ther was a change owner'
	select  @UserID = lfc.UserID,
		@UserGroupID = lfc.UserGroupID 
		from Accounting.tbl_Snapshots ss 
		inner join Accounting.tbl_LifeCycles lf on lf.LifeCycleID = ss.LifeCycleID 
		inner join CasinoLayout.Stocks st on st.StockID = lf.StockID
		inner JOIN Accounting.tbl_Snapshot_Confirmations lfc ON lfc.LifeCycleSnapShotID = ss.LifeCycleSnapShotID
		inner join 
			(
			select max(ss1.SnapshotTime) as ChOwnerTime
			from Accounting.tbl_Snapshots ss1 
			where ss1.LifeCycleID = @LifeCycleID
			and ss1.SnapshotTypeID = 4 --CHANGEOWNER
			and ss1.LCSnapshotCancelID is null
			) AA on AA.ChOwnerTime = ss.SnapshotTime
		and ss.LifeCycleID = @LifeCycleID 
		and ss.SnapshotTypeID = 4 --CHANGEOWNERgownID
	if @UserID is null
	begin
		raiserror('ChangeOwner for lifecycle %d exists but has no Confirmator!!',16,1,@LifeCycleID)
		return(1)
	end
	select @LastName = LastName,@FirstName = FirstName from CasinoLayout.Users where UserID = @UserID
end
else
begin
--no change owner snapshot exists just look for apertura snapshots
	if not exists 
		(
		select LifeCycleSnapshotID from Accounting.tbl_Snapshots 
		where LifeCycleID = @LifeCycleID 
		and SnapshotTypeID = 1 --APERTURA
		)
	begin
		raiserror('Lifecycle %d exists but is not open!!',16,1,@LifeCycleID)
		return(2)
	end
	else
	begin
		select @UserID = ua.UserID,
		       @UserGroupID = ua.UserGroupID
		from Accounting.tbl_Snapshots ss 
		inner join FloorActivity.tbl_UserAccesses ua on ua.UserAccessID = ss.UserAccessID 
		where ss.LifeCycleID = @LifeCycleID 
		and ss.SnapshotTypeID = 1 --APERTURA
		if @UserID is null
		begin
			raiserror('ChangeOwner for lifecycle %d exists but has no Confirmator!!',16,1,@LifeCycleID)
			return(1)
		end
		select @LastName = LastName,@FirstName = FirstName from CasinoLayout.Users where UserID = @UserID
	end
end

if @userid is null
begin
	raiserror('Could not identify owner ID of lifecycle %d',16,1,@LifeCycleID)
	return(0)
end
GO
