CREATE TABLE [CasinoLayout].[tbl_TorneiPoker]
(
[PK_TorneoID] [int] NOT NULL IDENTITY(1, 1),
[InizioIscrizioni] [datetime] NULL,
[FName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_TorneiPoker] ADD CONSTRAINT [PK_TorneiPoker] PRIMARY KEY CLUSTERED  ([PK_TorneoID]) ON [PRIMARY]
GO
