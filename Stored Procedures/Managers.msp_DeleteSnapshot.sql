SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_DeleteSnapshot] 
@ssid int
AS
print 'Deleting snapshot ' +str(@ssid)
delete from FloorActivity.tbl_SnapshotModifications where LifeCycleSnapshotID = @ssid
delete from Accounting.tbl_Snapshot_Confirmations where LifeCycleSnapshotID = @ssid
delete from Accounting.tbl_SnapshotValues where LifeCycleSnapshotID = @ssid
delete from Accounting.tbl_Snapshots where LifeCycleSnapshotID = @ssid
GO
