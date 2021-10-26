CREATE TABLE [Techs].[MaterialeTecnico_Articoli]
(
[MaterialeTecnicoID] [int] NOT NULL,
[FornitoreID] [int] NOT NULL,
[NumPezzi] [int] NULL,
[DescrizioneArticolo] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeTecnico_Articoli] ADD CONSTRAINT [FK_MaterialeTecnico_Articoli] FOREIGN KEY ([MaterialeTecnicoID]) REFERENCES [Techs].[MaterialeTecnico] ([MaterialeTecnicoID])
GO
ALTER TABLE [Techs].[MaterialeTecnico_Articoli] ADD CONSTRAINT [FK_MaterialeTecnico_Articoli_Fornitori] FOREIGN KEY ([FornitoreID]) REFERENCES [Techs].[Fornitori] ([FornitoreID])
GO
