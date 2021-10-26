CREATE TABLE [CasinoLayout].[Stocks]
(
[StockID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Tag] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StockTypeID] [int] NULL CONSTRAINT [DF_Stocks_StockTypeID] DEFAULT ((0)),
[MinBet] [int] NULL,
[VenditaEuro] [int] NULL,
[FromGamingDate] [smalldatetime] NULL,
[TillGamingDate] [smalldatetime] NULL,
[KioskID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Stocks] ADD CONSTRAINT [PK_ValueStocks] PRIMARY KEY CLUSTERED  ([StockID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Stocks] ADD CONSTRAINT [IX_Stocks_Tag_must_be_unique] UNIQUE NONCLUSTERED  ([Tag]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[Stocks] ADD CONSTRAINT [FK_Stocks_StockTypes] FOREIGN KEY ([StockTypeID]) REFERENCES [CasinoLayout].[StockTypes] ([StockTypeID])
GO
