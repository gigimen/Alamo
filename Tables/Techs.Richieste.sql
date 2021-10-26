CREATE TABLE [Techs].[Richieste]
(
[RichiestaID] [int] NOT NULL IDENTITY(1, 1),
[RichiestaTypeID] [int] NOT NULL,
[RichiedenteID] [int] NOT NULL,
[Nota] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_RichiesteInterventi_InsertTimeStampUTC] DEFAULT (getutcdate()),
[PrioritaID] [int] NOT NULL,
[InterventoID] [int] NULL,
[MaterialeFacilityID] [int] NULL,
[MaterialeTecnicoID] [int] NULL,
[PerQuando] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Richieste] ADD CONSTRAINT [PK_RichiesteInterventi] PRIMARY KEY CLUSTERED  ([RichiestaID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Richieste] ADD CONSTRAINT [FK_Richieste_Interventi] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[Interventi] ([InterventoID])
GO
ALTER TABLE [Techs].[Richieste] ADD CONSTRAINT [FK_Richieste_MaterialeFacility] FOREIGN KEY ([MaterialeFacilityID]) REFERENCES [Techs].[MaterialeFacility] ([MaterialeFacilityID])
GO
ALTER TABLE [Techs].[Richieste] ADD CONSTRAINT [FK_Richieste_MaterialeTecnico] FOREIGN KEY ([MaterialeTecnicoID]) REFERENCES [Techs].[MaterialeTecnico] ([MaterialeTecnicoID])
GO
ALTER TABLE [Techs].[Richieste] ADD CONSTRAINT [FK_Richieste_Priorita] FOREIGN KEY ([PrioritaID]) REFERENCES [Techs].[Priorita] ([PrioritaID])
GO
ALTER TABLE [Techs].[Richieste] ADD CONSTRAINT [FK_Richieste_Richiedenti] FOREIGN KEY ([RichiedenteID]) REFERENCES [Techs].[Richiedenti] ([RichiedenteID])
GO
ALTER TABLE [Techs].[Richieste] ADD CONSTRAINT [FK_Richieste_RichiestaTypes] FOREIGN KEY ([RichiestaTypeID]) REFERENCES [Techs].[RichiestaTypes] ([RichiestaTypeID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'Techs', 'TABLE', N'Richieste', 'COLUMN', N'RichiedenteID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'0=MaterialeFacility, 1=ServizioTecnici, 2=ServizioFacility', 'SCHEMA', N'Techs', 'TABLE', N'Richieste', 'COLUMN', N'RichiestaTypeID'
GO
