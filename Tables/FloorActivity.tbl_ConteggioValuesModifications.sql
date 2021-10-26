CREATE TABLE [FloorActivity].[tbl_ConteggioValuesModifications]
(
[ModID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[StockID] [int] NOT NULL,
[FromQuantity] [int] NOT NULL,
[ToQuantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_ConteggioValuesModifications] ADD CONSTRAINT [FK_tbl_ConteggioValuesModifications_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [FloorActivity].[tbl_ConteggioValuesModifications] ADD CONSTRAINT [FK_tbl_ConteggioValuesModifications_Stocks] FOREIGN KEY ([StockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
ALTER TABLE [FloorActivity].[tbl_ConteggioValuesModifications] ADD CONSTRAINT [FK_tbl_ConteggioValuesModifications_tbl_ConteggiModifications] FOREIGN KEY ([ModID]) REFERENCES [FloorActivity].[tbl_ConteggiModifications] ([ModID])
GO
