CREATE TABLE [CasinoLayout].[Site_App_Stock]
(
[SiteID] [int] NOT NULL,
[ApplicationID] [int] NOT NULL,
[StockID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Site_App_Stock] ADD CONSTRAINT [PK_Site_Application] PRIMARY KEY CLUSTERED  ([SiteID], [ApplicationID], [StockID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Site_App_Stock] WITH NOCHECK ADD CONSTRAINT [FK_Site_App_Stock_Stocks] FOREIGN KEY ([StockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
ALTER TABLE [CasinoLayout].[Site_App_Stock] WITH NOCHECK ADD CONSTRAINT [FK_Site_Application_Applications] FOREIGN KEY ([ApplicationID]) REFERENCES [GeneralPurpose].[Applications] ([ApplicationID])
GO
ALTER TABLE [CasinoLayout].[Site_App_Stock] WITH NOCHECK ADD CONSTRAINT [FK_Site_Program_Sites] FOREIGN KEY ([SiteID]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
