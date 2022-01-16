CREATE TABLE [Reception].[tbl_VetoControls]
(
[PK_ControllID] [int] NOT NULL IDENTITY(1, 1),
[TimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_VetoControls_TimeStampUTC] DEFAULT (getutcdate()),
[searchString] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HitsNumber] [int] NOT NULL,
[SiteId] [int] NOT NULL,
[TimeStampLoc] [datetime] NOT NULL CONSTRAINT [DF_tbl_VetoControls_TimeStampLoc] DEFAULT (getdate()),
[GamingDate] [datetime] NOT NULL CONSTRAINT [DF_tbl_VetoControls_GamingDate] DEFAULT ([GeneralPurpose].[fn_GetGamingLocalDate2](getdate(),(0),(22))),
[UserID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Reception].[tbl_VetoControls] ADD CONSTRAINT [PK_tbl_VetoControls] PRIMARY KEY CLUSTERED  ([PK_ControllID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbl_VetoControls_GamingDate] ON [Reception].[tbl_VetoControls] ([GamingDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VetoControls_by_GamingDate] ON [Reception].[tbl_VetoControls] ([GamingDate]) INCLUDE ([SiteId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbl_VetoControls_searchString] ON [Reception].[tbl_VetoControls] ([searchString]) ON [PRIMARY]
GO
ALTER TABLE [Reception].[tbl_VetoControls] ADD CONSTRAINT [FK_VetoControls_Sites] FOREIGN KEY ([SiteId]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
ALTER TABLE [Reception].[tbl_VetoControls] ADD CONSTRAINT [FK_VetoControls_Users] FOREIGN KEY ([UserID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
