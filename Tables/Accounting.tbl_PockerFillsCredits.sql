CREATE TABLE [Accounting].[tbl_PockerFillsCredits]
(
[PK_ID] [int] NOT NULL IDENTITY(1, 1),
[FK_FillTransID] [int] NOT NULL,
[FK_CreditTransID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_PockerFillsCredits] ADD CONSTRAINT [PK_PockerTransactions] PRIMARY KEY CLUSTERED  ([PK_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbl_PockerFill] ON [Accounting].[tbl_PockerFillsCredits] ([FK_FillTransID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_PockerFillsCredits] WITH NOCHECK ADD CONSTRAINT [FK_PockerTransactions_Credit] FOREIGN KEY ([FK_CreditTransID]) REFERENCES [Accounting].[tbl_Transactions] ([TransactionID])
GO
ALTER TABLE [Accounting].[tbl_PockerFillsCredits] WITH NOCHECK ADD CONSTRAINT [FK_PockerTransactions_Fill] FOREIGN KEY ([FK_FillTransID]) REFERENCES [Accounting].[tbl_Transactions] ([TransactionID])
GO
