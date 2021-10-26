CREATE TABLE [CasinoLayout].[TransactionFlows]
(
[SourceStockTypeID] [int] NOT NULL,
[DestStockTypeID] [int] NOT NULL,
[OpTypeID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[TransactionFlows] ADD CONSTRAINT [PK_TransactionFlows] PRIMARY KEY CLUSTERED  ([SourceStockTypeID], [DestStockTypeID], [OpTypeID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[TransactionFlows] WITH NOCHECK ADD CONSTRAINT [FK_TransactionFlows_DestStockTypes] FOREIGN KEY ([DestStockTypeID]) REFERENCES [CasinoLayout].[StockTypes] ([StockTypeID])
GO
ALTER TABLE [CasinoLayout].[TransactionFlows] WITH NOCHECK ADD CONSTRAINT [FK_TransactionFlows_OperationTypes] FOREIGN KEY ([OpTypeID]) REFERENCES [CasinoLayout].[OperationTypes] ([OpTypeID])
GO
ALTER TABLE [CasinoLayout].[TransactionFlows] WITH NOCHECK ADD CONSTRAINT [FK_TransactionFlows_SourceStockTypes] FOREIGN KEY ([SourceStockTypeID]) REFERENCES [CasinoLayout].[StockTypes] ([StockTypeID])
GO
