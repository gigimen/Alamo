CREATE TABLE [Accounting].[tbl_Conteggi]
(
[ConteggioID] [int] NOT NULL IDENTITY(1, 1),
[SnapshotTypeID] [int] NOT NULL,
[GamingDate] [datetime] NOT NULL,
[ConteggioTimeUTC] [datetime] NOT NULL,
[UserAccessID] [int] NOT NULL,
[CancelID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Conteggi] ADD CONSTRAINT [PK_tbl_Conteggi] PRIMARY KEY CLUSTERED  ([ConteggioID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Conteggi_GamingDate] ON [Accounting].[tbl_Conteggi] ([ConteggioID], [SnapshotTypeID], [GamingDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Conteggi_SnapShotTypeID] ON [Accounting].[tbl_Conteggi] ([SnapshotTypeID], [GamingDate], [CancelID]) INCLUDE ([ConteggioID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Conteggi] WITH NOCHECK ADD CONSTRAINT [FK_tbl_Conteggi_ConteggioCanceled] FOREIGN KEY ([CancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [Accounting].[tbl_Conteggi] WITH NOCHECK ADD CONSTRAINT [FK_tbl_Conteggi_tbl_SnapshotTypes] FOREIGN KEY ([SnapshotTypeID]) REFERENCES [CasinoLayout].[SnapshotTypes] ([SnapshotTypeID])
GO
ALTER TABLE [Accounting].[tbl_Conteggi] WITH NOCHECK ADD CONSTRAINT [FK_tbl_Conteggi_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
