CREATE TABLE [Techs].[MaterialeFacility]
(
[MaterialeFacilityID] [int] NOT NULL IDENTITY(1, 1),
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_MaterialeFacility_InsertTimeStampUTC] DEFAULT (getutcdate()),
[OwnerUserID] [int] NOT NULL,
[Descrizione] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatoOrdineID] [int] NOT NULL,
[RichiedenteID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeFacility] ADD CONSTRAINT [PK_MaterialeFacility] PRIMARY KEY CLUSTERED  ([MaterialeFacilityID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeFacility] ADD CONSTRAINT [FK_MaterialeFacility_Richiedenti] FOREIGN KEY ([RichiedenteID]) REFERENCES [Techs].[Richiedenti] ([RichiedenteID])
GO
ALTER TABLE [Techs].[MaterialeFacility] ADD CONSTRAINT [FK_MaterialeFacility_StatiOrdine] FOREIGN KEY ([StatoOrdineID]) REFERENCES [Techs].[StatiOrdine] ([StatoOrdineID])
GO
ALTER TABLE [Techs].[MaterialeFacility] ADD CONSTRAINT [FK_MaterialeFacility_Users] FOREIGN KEY ([OwnerUserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
