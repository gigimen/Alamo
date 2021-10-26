CREATE TABLE [CasinoLayout].[StockTypes]
(
[StockTypeID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChangeOfGamingDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GamingDateDelayed] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[StockTypes] ADD CONSTRAINT [PK_StockTypes] PRIMARY KEY CLUSTERED  ([StockTypeID]) ON [PRIMARY]
GO
