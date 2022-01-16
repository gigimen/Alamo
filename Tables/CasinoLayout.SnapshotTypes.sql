CREATE TABLE [CasinoLayout].[SnapshotTypes]
(
[SnapshotTypeID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ForStockTypeID] [int] NULL,
[SorvDoubleCheck] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[SnapshotTypes] ADD CONSTRAINT [PK_SnapshotTypes] PRIMARY KEY CLUSTERED  ([SnapshotTypeID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'1=Tipo di conteggio doppio eseguito da sroveglianza via vedocamera', 'SCHEMA', N'CasinoLayout', 'TABLE', N'SnapshotTypes', 'COLUMN', N'SorvDoubleCheck'
GO
