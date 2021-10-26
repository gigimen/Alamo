CREATE TABLE [Accounting].[tbl_SnapshotValues]
(
[LifeCycleSnapshotID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[Quantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_SnapshotValues] ADD CONSTRAINT [PK_FreezeValues] PRIMARY KEY CLUSTERED  ([LifeCycleSnapshotID], [DenoID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LifeCycleValues_By_DenoID] ON [Accounting].[tbl_SnapshotValues] ([DenoID]) INCLUDE ([LifeCycleSnapshotID], [Quantity]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_SnapshotValues] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleValues_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [Accounting].[tbl_SnapshotValues] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycleValues_LifeCycleSnapshot] FOREIGN KEY ([LifeCycleSnapshotID]) REFERENCES [Accounting].[tbl_Snapshots] ([LifeCycleSnapshotID])
GO
