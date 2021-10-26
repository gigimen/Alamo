CREATE TABLE [Accounting].[tbl_LifeCycles]
(
[LifeCycleID] [int] NOT NULL IDENTITY(1, 1),
[StockID] [int] NOT NULL,
[GamingDate] [smalldatetime] NOT NULL,
[StockCompositionID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_LifeCycles] ADD CONSTRAINT [PK_LifeCycleID] PRIMARY KEY CLUSTERED  ([LifeCycleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GamingDate] ON [Accounting].[tbl_LifeCycles] ([GamingDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LifeCycles_OnStockIDGamingDate] ON [Accounting].[tbl_LifeCycles] ([StockID], [GamingDate]) INCLUDE ([LifeCycleID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_LifeCycles] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycles_StockCompositions] FOREIGN KEY ([StockCompositionID]) REFERENCES [CasinoLayout].[StockCompositions] ([StockCompositionID])
GO
ALTER TABLE [Accounting].[tbl_LifeCycles] WITH NOCHECK ADD CONSTRAINT [FK_LifeCycles_Stocks] FOREIGN KEY ([StockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
