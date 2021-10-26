CREATE TABLE [Accounting].[tbl_ConteggiValues]
(
[ConteggioID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[StockID] [int] NOT NULL,
[Quantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_ConteggiValues] ADD CONSTRAINT [PK_ConteggiValues] PRIMARY KEY CLUSTERED  ([DenoID], [ConteggioID], [StockID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ConteggiValues_ConteggioID] ON [Accounting].[tbl_ConteggiValues] ([ConteggioID]) INCLUDE ([DenoID], [ExchangeRate], [Quantity], [StockID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_ConteggiValues] ADD CONSTRAINT [FK_tbl_ConteggiValues_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [Accounting].[tbl_ConteggiValues] WITH NOCHECK ADD CONSTRAINT [FK_tbl_ConteggiValues_Stocks] FOREIGN KEY ([StockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
ALTER TABLE [Accounting].[tbl_ConteggiValues] WITH NOCHECK ADD CONSTRAINT [FK_tbl_ConteggiValues_tbl_Conteggi] FOREIGN KEY ([ConteggioID]) REFERENCES [Accounting].[tbl_Conteggi] ([ConteggioID])
GO
