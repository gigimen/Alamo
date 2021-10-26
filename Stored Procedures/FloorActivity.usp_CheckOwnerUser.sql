SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [FloorActivity].[usp_CheckOwnerUser] 
@LifeCycleID int,
@UserID int,
@yes int output
AS
--run some checks on input data
if not exists( select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
begin
	raiserror('Must specify a valid LifeCycleID',16,1)
	return(0)
end
if not exists( select UserID from CasinoLayout.Users where UserID = @UserID)
begin
	raiserror('Must specify a valid UserID',16,1)
	return(0)
end
--first check that some change owner snapshot exist
if exists ( select LifeCycleSnapshotID 
		from Accounting.tbl_Snapshots ss
		where ss.LifeCycleID = @LifeCycleID
		and ss.SnapshotTypeID = 4 --CHANGEOWNER
		and ss.LCSnapshotCancelId is null
	)

--then check that the last one is for the user
begin
	if exists (
		select sc.LifeCycleSnapshotID from Accounting.tbl_Snapshots ss
		INNER JOIN Accounting.tbl_Snapshot_Confirmations sc 
		ON sc.LifeCycleSnapShotID = ss.LifeCycleSnapShotID
		where ss.SnapshotTime =
			(
			select max(SnapshotTime) 
			from Accounting.tbl_Snapshots 
			where LifeCycleID = @LifeCycleID
			and LCSnapShotCancelID IS NULL
			and SnapshotTypeID = 4 --CHANGEOWNER
			and LCSnapshotCancelId is null
			) 
		and ss.LifeCycleID = @LifeCycleID 
		and ss.SnapshotTypeID = 4 --CHANGEOWNER
		and ss.LCSnapshotCancelId is null
		and sc.UserID = @UserID)
		set @yes = 1
	else
		--the last changeowner id not for this user
		set @yes = 0
end
else
begin
--no change owner snapshot exists just look for apertura snapshots
	if exists 
		(
		select LifeCycleSnapshotID from Accounting.tbl_Snapshots ss 
		inner join FloorActivity.tbl_UserAccesses Ua on UA.UserAccessID = ss.UserAccessID
		where ss.LifeCycleID = @LifeCycleID 
		and ua.UserID = @UserID
		and ss.LCSnapShotCancelID IS NULL
		and ss.SnapshotTypeID = 1 --APERTURA
		)
			set @yes = 1
		else
			--the owner is not this user
			set @yes = 0
end
GO
