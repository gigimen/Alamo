CREATE TABLE [Accounting].[tbl_Snapshot_Confirmations]
(
[LifeCycleSnapshotID] [int] NOT NULL,
[UserID] [int] NOT NULL,
[UserGroupID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Snapshot_Confirmations] ADD CONSTRAINT [PK_LifeCycle_Confirmations] PRIMARY KEY CLUSTERED  ([LifeCycleSnapshotID], [UserID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Snapshot_Confirmations] ADD CONSTRAINT [FK_LifeCycle_Confirmations_LifeCycleSnapshots] FOREIGN KEY ([LifeCycleSnapshotID]) REFERENCES [Accounting].[tbl_Snapshots] ([LifeCycleSnapshotID])
GO
ALTER TABLE [Accounting].[tbl_Snapshot_Confirmations] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycle_Confirmations_UserGroups] FOREIGN KEY ([UserGroupID]) REFERENCES [CasinoLayout].[UserGroups] ([UserGroupID])
GO
ALTER TABLE [Accounting].[tbl_Snapshot_Confirmations] ADD CONSTRAINT [FK_LifeCycle_Confirmations_Users] FOREIGN KEY ([UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
