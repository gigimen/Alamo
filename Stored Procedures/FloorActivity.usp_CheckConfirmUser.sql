SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [FloorActivity].[usp_CheckConfirmUser] 
@LifeCycleID int,
@UserID int,
@ssTypeID int,
@yes int output
AS
--in case we did not specify an operation by default check the apertura confirmation
if(@ssTypeID is null)
	select @ssTypeID = SnapshotTypeID from CasinoLayout.SnapshotTypes where FName = 'Apertura'
if exists (select Accounting.tbl_Snapshot_Confirmations.LifeCycleSnapshotID from Accounting.tbl_Snapshot_Confirmations
INNER JOIN Accounting.tbl_Snapshots SSType 
	ON SSType.LifeCycleSnapshotID = Accounting.tbl_Snapshot_Confirmations.LifeCycleSnapshotID 
	--snapshot has not been cancelled
	AND SSType.LCSnapShotCancelID IS NULL
	where SSType.LifeCycleID = @LifeCycleID 
	and Accounting.tbl_Snapshot_Confirmations.UserID = @UserID 
	and SSType.SnapshotTypeID = @ssTypeID
  )
	set @yes = 1
else
	set @yes = 0

GO
