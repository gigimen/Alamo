CREATE TABLE [Techs].[Interventi]
(
[InterventoID] [int] NOT NULL IDENTITY(1, 1),
[InterventoTimeStampUTC] [datetime] NOT NULL,
[OwnerUserID] [int] NOT NULL,
[Tecnico2UserID] [int] NULL,
[Descrizione] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatoTypeID] [int] NOT NULL,
[RichiedenteID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Interventi] ADD CONSTRAINT [PK_Techs_Interventi] PRIMARY KEY CLUSTERED  ([InterventoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[Interventi] ADD CONSTRAINT [FK_Interventi_Richiedenti] FOREIGN KEY ([RichiedenteID]) REFERENCES [Techs].[Richiedenti] ([RichiedenteID])
GO
ALTER TABLE [Techs].[Interventi] ADD CONSTRAINT [FK_Interventi_StatoTypes] FOREIGN KEY ([StatoTypeID]) REFERENCES [Techs].[StatoTypes] ([StatoTypeID])
GO
ALTER TABLE [Techs].[Interventi] ADD CONSTRAINT [FK_Interventi_Users_2ndTecnico] FOREIGN KEY ([Tecnico2UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
ALTER TABLE [Techs].[Interventi] ADD CONSTRAINT [FK_Interventi_Users_Owner] FOREIGN KEY ([OwnerUserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
