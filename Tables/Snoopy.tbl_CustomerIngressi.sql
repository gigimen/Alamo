CREATE TABLE [Snoopy].[tbl_CustomerIngressi]
(
[entratatimestampUTC] [datetime] NOT NULL CONSTRAINT [DF_EntrateGoldenClub_entratatimestampUTC] DEFAULT (getutcdate()),
[CustomerID] [int] NOT NULL,
[SiteID] [int] NOT NULL,
[CardID] [int] NULL,
[Osservazione] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entratatimestampLoc] [datetime] NOT NULL CONSTRAINT [DF_Ingressi_entratatimestampLoc] DEFAULT (getdate()),
[GamingDate] [datetime] NOT NULL CONSTRAINT [DF_Ingressi_GamingDate] DEFAULT ([GeneralPurpose].[fn_GetGamingLocalDate2](getdate(),(0),(22))),
[UserID] [int] NULL,
[IsUscita] [bit] NULL,
[FK_CardEntryModeID] [int] NULL,
[FK_ControlID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ingressi_PerCustomerAndGamingDate] ON [Snoopy].[tbl_CustomerIngressi] ([CustomerID], [GamingDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EntrateGoldenClub] ON [Snoopy].[tbl_CustomerIngressi] ([entratatimestampUTC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INGRESSI_GAMINGDATE_CUSTOMERID] ON [Snoopy].[tbl_CustomerIngressi] ([GamingDate]) INCLUDE ([CustomerID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerIngressi] WITH NOCHECK ADD CONSTRAINT [FK_EntrateGoldenClub_GoldenClubCards] FOREIGN KEY ([CardID]) REFERENCES [GoldenClub].[tbl_Cards] ([GoldenClubCardID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerIngressi] WITH NOCHECK ADD CONSTRAINT [FK_EntrateGoldenClub_Sites] FOREIGN KEY ([SiteID]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerIngressi] ADD CONSTRAINT [FK_Ingressi_CardEntryMode] FOREIGN KEY ([FK_CardEntryModeID]) REFERENCES [GoldenClub].[tbl_CardEntryMode] ([PK_CardEntryModeID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerIngressi] ADD CONSTRAINT [FK_Ingressi_Ingressi_VetoControl] FOREIGN KEY ([FK_ControlID]) REFERENCES [Snoopy].[tbl_VetoControls] ([PK_ControllID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerIngressi] WITH NOCHECK ADD CONSTRAINT [FK_Ingressi_Users] FOREIGN KEY ([UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
