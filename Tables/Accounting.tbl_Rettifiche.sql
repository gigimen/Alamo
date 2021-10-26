CREATE TABLE [Accounting].[tbl_Rettifiche]
(
[FK_LifeCycleID] [int] NOT NULL,
[FK_LifeCycleSnapshotID] [int] NOT NULL,
[EURCents] [int] NULL,
[CHFCents] [int] NULL,
[Nota] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_Rettifiche_TimeStampUTC] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Rettifiche] ADD CONSTRAINT [PK_tbl_Rettifiche] PRIMARY KEY CLUSTERED  ([FK_LifeCycleID], [FK_LifeCycleSnapshotID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Rettifiche] ADD CONSTRAINT [FK_tbl_Rettifiche_LifeCycles] FOREIGN KEY ([FK_LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Accounting].[tbl_Rettifiche] ADD CONSTRAINT [FK_tbl_Rettifiche_LifeCycleSnapshots] FOREIGN KEY ([FK_LifeCycleSnapshotID]) REFERENCES [Accounting].[tbl_Snapshots] ([LifeCycleSnapshotID])
GO
