CREATE TABLE [CasinoLayout].[Jackpots]
(
[JackpotID] [int] NOT NULL,
[JackpotName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JpID] [varchar] (4) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Jackpots] ADD CONSTRAINT [PK_Jackpots] PRIMARY KEY CLUSTERED  ([JackpotID]) ON [PRIMARY]
GO
