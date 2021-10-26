CREATE TABLE [CasinoLayout].[Sites]
(
[SiteID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ComputerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CashlessTerminal] [int] NULL,
[OcchioPort] [int] NULL,
[AdunoTerminal] [bit] NULL,
[GlobalCash] [bit] NULL,
[SesamEntranceID] [int] NULL,
[CornerBank] [bit] NULL,
[SiteTypeID] [int] NULL,
[JackpotReceiver] [bit] NULL,
[ComputerIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketTerminal] [int] NULL,
[DRGTNetworkAddr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DRGTPortNo] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Sites] ADD CONSTRAINT [PK_InspectorSites] PRIMARY KEY CLUSTERED  ([SiteID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Sites] ADD CONSTRAINT [IX_Sites_ComputerName_is_unique] UNIQUE NONCLUSTERED  ([ComputerName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_NomeUnico] ON [CasinoLayout].[Sites] ([FName]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Sites] ADD CONSTRAINT [FK_Sites_SiteTypes] FOREIGN KEY ([SiteTypeID]) REFERENCES [CasinoLayout].[SiteTypes] ([SiteTypeID])
GO
GRANT SELECT ON  [CasinoLayout].[Sites] TO [CKeyUsage]
GO
