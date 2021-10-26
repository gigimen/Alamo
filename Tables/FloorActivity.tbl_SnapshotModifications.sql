CREATE TABLE [FloorActivity].[tbl_SnapshotModifications]
(
[ModID] [int] NOT NULL IDENTITY(1, 1),
[UserAccessID] [int] NOT NULL,
[ModDate] [datetime] NOT NULL CONSTRAINT [DF_SnapshotModifications_ModDate] DEFAULT (getutcdate()),
[LifeCycleSnapshotID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[FromQuantity] [int] NOT NULL,
[ToQuantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_SnapshotModifications] ADD CONSTRAINT [PK_SnapshotModifications] PRIMARY KEY CLUSTERED  ([ModID]) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_SnapshotModifications] ADD CONSTRAINT [FK_SnapshotModifications_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [FloorActivity].[tbl_SnapshotModifications] ADD CONSTRAINT [FK_SnapshotModifications_LifeCycleSnapshots] FOREIGN KEY ([LifeCycleSnapshotID]) REFERENCES [Accounting].[tbl_Snapshots] ([LifeCycleSnapshotID])
GO
ALTER TABLE [FloorActivity].[tbl_SnapshotModifications] ADD CONSTRAINT [FK_SnapshotModifications_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
