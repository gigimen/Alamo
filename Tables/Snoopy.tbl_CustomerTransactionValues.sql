CREATE TABLE [Snoopy].[tbl_CustomerTransactionValues]
(
[DenoID] [int] NOT NULL,
[CustomerTransactionID] [int] NOT NULL,
[Quantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL,
[CashInbound] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactionValues] ADD CONSTRAINT [PK_CustomerTransactionValues] PRIMARY KEY CLUSTERED  ([DenoID], [CustomerTransactionID], [CashInbound]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerTransactionValues_CustomerTransactionID] ON [Snoopy].[tbl_CustomerTransactionValues] ([CustomerTransactionID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactionValues] WITH NOCHECK ADD CONSTRAINT [FK_CustomerTransactionValues_CustomerTransactions] FOREIGN KEY ([CustomerTransactionID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactionValues] WITH NOCHECK ADD CONSTRAINT [FK_CustomerTransactionValues_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
