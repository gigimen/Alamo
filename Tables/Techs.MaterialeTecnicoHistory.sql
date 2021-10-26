CREATE TABLE [Techs].[MaterialeTecnicoHistory]
(
[MaterialeTecnicoHistoryID] [int] NOT NULL IDENTITY(1, 1),
[MaterialeTecnicoID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_MaterialeTecnicoHistory_InsertTimeStampUTC] DEFAULT (getutcdate()),
[InsertUserAccessID] [int] NOT NULL,
[HistDescr] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeTecnicoHistory] ADD CONSTRAINT [PK_MaterialeTecnicoHistory] PRIMARY KEY CLUSTERED  ([MaterialeTecnicoHistoryID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeTecnicoHistory] ADD CONSTRAINT [FK_MateraileTecnicoHistory_UserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [Techs].[MaterialeTecnicoHistory] ADD CONSTRAINT [FK_MaterialeTecnicoHistory_MaterialeTecnico] FOREIGN KEY ([MaterialeTecnicoID]) REFERENCES [Techs].[MaterialeTecnico] ([MaterialeTecnicoID])
GO
