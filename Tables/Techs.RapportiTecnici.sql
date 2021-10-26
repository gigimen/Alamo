CREATE TABLE [Techs].[RapportiTecnici]
(
[InterventoID] [int] NOT NULL,
[Problema] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Soluzione] [varchar] (4096) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[RapportiTecnici] ADD CONSTRAINT [PK_RapportiTecnici] PRIMARY KEY CLUSTERED  ([InterventoID]) ON [PRIMARY]
GO
ALTER TABLE [Techs].[RapportiTecnici] ADD CONSTRAINT [FK_RapportiTecnici_InterventiSlot] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[InterventiSlot] ([InterventoID])
GO
