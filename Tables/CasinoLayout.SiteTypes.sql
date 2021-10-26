CREATE TABLE [CasinoLayout].[SiteTypes]
(
[SiteTypeID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[SiteTypes] ADD CONSTRAINT [PK_SiteTypes] PRIMARY KEY CLUSTERED  ([SiteTypeID]) ON [PRIMARY]
GO
