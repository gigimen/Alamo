CREATE TABLE [CasinoLayout].[StockComposition_Denominations]
(
[StockCompositionID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[InitialQty] [int] NULL,
[ModuleValue] [int] NULL,
[WeightInTotal] [smallint] NOT NULL,
[AutomaticFill] [int] NULL,
[AllowNegative] [smallint] NULL,
[IsRiserva] [bit] NOT NULL CONSTRAINT [DF_StockComposition_Denominations_IsRiserva] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[StockComposition_Denominations] WITH NOCHECK ADD CONSTRAINT [CK_StockComposition_Denominations_Riserva] CHECK NOT FOR REPLICATION (([IsRiserva]=(1) AND [Denoid]>=(121) AND [Denoid]<=(127) OR [IsRiserva]=(0) AND NOT ([Denoid]>=(121) AND [Denoid]<=(127))))
GO
ALTER TABLE [CasinoLayout].[StockComposition_Denominations] NOCHECK CONSTRAINT [CK_StockComposition_Denominations_Riserva]
GO
ALTER TABLE [CasinoLayout].[StockComposition_Denominations] ADD CONSTRAINT [PK_StockComposition_Denominations] PRIMARY KEY CLUSTERED  ([StockCompositionID], [DenoID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[StockComposition_Denominations] WITH NOCHECK ADD CONSTRAINT [FK_StockComposition_Denomiations_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [CasinoLayout].[StockComposition_Denominations] WITH NOCHECK ADD CONSTRAINT [FK_StockComposition_Denomiations_StockCompositions] FOREIGN KEY ([StockCompositionID]) REFERENCES [CasinoLayout].[StockCompositions] ([StockCompositionID])
GO
