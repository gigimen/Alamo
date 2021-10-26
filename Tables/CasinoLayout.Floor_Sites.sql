CREATE TABLE [CasinoLayout].[Floor_Sites]
(
[SiteID] [int] NOT NULL,
[FloorID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Floor_Sites] ADD CONSTRAINT [PK_Floor_Sites] PRIMARY KEY CLUSTERED  ([SiteID], [FloorID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Floor_Sites] ADD CONSTRAINT [FK_Floor_Sites_Floors] FOREIGN KEY ([FloorID]) REFERENCES [CasinoLayout].[Floors] ([FloorID])
GO
ALTER TABLE [CasinoLayout].[Floor_Sites] WITH NOCHECK ADD CONSTRAINT [FK_Floor_Sites_Sites] FOREIGN KEY ([SiteID]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
