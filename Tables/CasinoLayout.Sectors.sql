CREATE TABLE [CasinoLayout].[Sectors]
(
[SectorID] [int] NOT NULL IDENTITY(1, 1),
[SectorName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SectorDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Sectors] ADD CONSTRAINT [PK_Sectors] PRIMARY KEY CLUSTERED  ([SectorID]) ON [PRIMARY]
GO
GRANT SELECT ON  [CasinoLayout].[Sectors] TO [CKeyUsage]
GO
