CREATE TABLE [GoldenClub].[tbl_PartecipazioneCena]
(
[CenaID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GoldenClubPartecipazioneCena_InsertTimeStampUTC] DEFAULT (getutcdate()),
[SiteID] [int] NOT NULL,
[Accompagnatori] [int] NULL,
[TipoCenaID] [int] NOT NULL,
[GamingDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneCena] ADD CONSTRAINT [PK_GoldenClubPartecipazioneCena] PRIMARY KEY CLUSTERED  ([CenaID]) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneCena] ADD CONSTRAINT [FK_GoldenClubPartecipazioneCena_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneCena] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubPartecipazioneCena_Sites] FOREIGN KEY ([SiteID]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneCena] ADD CONSTRAINT [FK_GoldenClubPartecipazioneCena_TipoCene] FOREIGN KEY ([TipoCenaID]) REFERENCES [GoldenClub].[tbl_TipoCene] ([TipoCenaID])
GO
