SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_WhoIsResponsibleForSnapshot]
@SnapshotID int
AS

if not exists (select LifeCycleSnapshotID from Accounting.tbl_Snapshots where LifeCycleSnapshotID = @SnapshotID)
begin
	raiserror('Must specifY a valid snapshot ID',16,1)
	return(1)
end
--we want to see who is responsible of the creation of this snapshot and who confirm it
SELECT  SUGID.RoleName 				AS RespRole,
	SUID.FirstName + ' ' + SUID.LastName 	AS Responsible,
	CUGID.RoleName 				As ConfRole,
	CUID.FirstName + ' ' + CUID.LastName 	AS Confirmator,
        Accounting.tbl_Snapshots.LifeCycleID, 
	CasinoLayout.SnapshotTypes.FName			AS OperationName,
	Accounting.tbl_LifeCycles.GamingDate,
	GeneralPurpose.fn_UTCToLocal(1,Accounting.tbl_Snapshots.SnapshotTime) as SnapshotTimeLoc
	FROM    Accounting.tbl_Snapshots 
        INNER JOIN CasinoLayout.SnapshotTypes ON CasinoLayout.SnapshotTypes.SnapshotTypeID = Accounting.tbl_Snapshots.SnapShotTypeID 
        INNER JOIN Accounting.tbl_LifeCycles ON Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_Snapshots.LifeCycleID 
        INNER JOIN FloorActivity.tbl_UserAccesses SUAID ON SUAID.UserAccessID = Accounting.tbl_Snapshots.UserAccessID 
	INNER JOIN CasinoLayout.Users SUID ON SUAID.UserID = SUID.UserID
	INNER JOIN CasinoLayout.UserGroups SUGID ON SUAID.UserGroupID = SUGID.UserGroupID
	LEFT OUTER JOIN Accounting.tbl_Snapshot_Confirmations
	ON (Accounting.tbl_Snapshot_Confirmations.LifeCycleSnapshotID = Accounting.tbl_Snapshots.LifeCycleSnapshotID)
	LEFT OUTER JOIN CasinoLayout.Users CUID 
	ON CUID.UserID = Accounting.tbl_Snapshot_Confirmations.UserID
	LEFT OUTER JOIN CasinoLayout.UserGroups CUGID 
	ON CUGID.UserGroupID = Accounting.tbl_Snapshot_Confirmations.UserGroupID
WHERE 	Accounting.tbl_Snapshots.LifeCycleSnapshotID = @SnapshotID
	and Accounting.tbl_Snapshots.LCSnapshotCancelID is null
	
GO
GRANT EXECUTE ON  [Accounting].[usp_WhoIsResponsibleForSnapshot] TO [SolaLetturaNoDanni]
GO
