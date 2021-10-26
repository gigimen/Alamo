CREATE TABLE [GoldenClub].[tbl_PartecipazioneEventi]
(
[EventoID] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[TimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_GoldenClubPartecipazioneEventi_TimeStampUTC] DEFAULT (getutcdate()),
[SiteID] [int] NOT NULL,
[Accompagnatori] [int] NULL,
[Winner] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneEventi] ADD CONSTRAINT [PK_GoldenClubPartecipazioneEventi] PRIMARY KEY CLUSTERED  ([TimeStampUTC], [EventoID], [CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneEventi] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubPartecipazioneEventi_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneEventi] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubPartecipazioneEventi_GoldenClubEventiMarketing] FOREIGN KEY ([EventoID]) REFERENCES [Marketing].[tbl_Eventi] ([EventoID])
GO
ALTER TABLE [GoldenClub].[tbl_PartecipazioneEventi] WITH NOCHECK ADD CONSTRAINT [FK_GoldenClubPartecipazioneEventi_Sites] FOREIGN KEY ([SiteID]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
