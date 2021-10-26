CREATE TABLE [Techs].[MaterialeTecnico]
(
[MaterialeTecnicoID] [int] NOT NULL IDENTITY(1, 1),
[InsertTimeStampUTC] [datetime] NOT NULL,
[OwnerUserID] [int] NULL,
[Descrizione] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatoOrdineID] [int] NOT NULL,
[RichiedenteID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeTecnico] ADD CONSTRAINT [PK_MaterialeTecnico] PRIMARY KEY CLUSTERED  ([MaterialeTecnicoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeTecnico] ADD CONSTRAINT [FK_MaterialeTecnico_Richiedenti] FOREIGN KEY ([RichiedenteID]) REFERENCES [Techs].[Richiedenti] ([RichiedenteID])
GO
ALTER TABLE [Techs].[MaterialeTecnico] ADD CONSTRAINT [FK_MaterialeTecnico_StatiOrdine] FOREIGN KEY ([StatoOrdineID]) REFERENCES [Techs].[StatiOrdine] ([StatoOrdineID])
GO
ALTER TABLE [Techs].[MaterialeTecnico] ADD CONSTRAINT [FK_MaterialeTecnico_Users] FOREIGN KEY ([OwnerUserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
