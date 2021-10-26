CREATE TABLE [Techs].[MaterialeFacility_Articoli]
(
[MaterialeFacilityID] [int] NOT NULL,
[FornitoreID] [int] NOT NULL,
[NumPezzi] [int] NULL,
[DescrizioneArticolo] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Techs].[MaterialeFacility_Articoli] ADD CONSTRAINT [FK_MaterialeFacility_Articoli_Facility] FOREIGN KEY ([MaterialeFacilityID]) REFERENCES [Techs].[MaterialeFacility] ([MaterialeFacilityID])
GO
ALTER TABLE [Techs].[MaterialeFacility_Articoli] ADD CONSTRAINT [FK_MaterialeFacility_Articoli_Fornitori] FOREIGN KEY ([FornitoreID]) REFERENCES [Techs].[Fornitori] ([FornitoreID])
GO
