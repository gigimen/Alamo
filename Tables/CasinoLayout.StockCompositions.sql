CREATE TABLE [CasinoLayout].[StockCompositions]
(
[StockCompositionID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[StockCompositions] ADD CONSTRAINT [PK_StockCompositions] PRIMARY KEY CLUSTERED  ([StockCompositionID]) ON [PRIMARY]
GO
