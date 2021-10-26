CREATE TABLE [Snoopy].[tbl_CartediCredito]
(
[CreditCardTransID] [int] NOT NULL IDENTITY(1, 1),
[FK_IDDocumentID] [int] NOT NULL,
[FK_CustomerTransactionID] [int] NOT NULL,
[FK_EuroTransactionID] [int] NULL,
[FK_MovimentoGettoniGiocoEuroID] [int] NULL,
[Commissione] [float] NOT NULL CONSTRAINT [DF_tbl_CartediCredito_Commissione] DEFAULT ((0)),
[FK_ContropartitaID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CartediCredito] ADD CONSTRAINT [PK_tbl_CartediCredito] PRIMARY KEY CLUSTERED  ([CreditCardTransID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CartediCredito] WITH NOCHECK ADD CONSTRAINT [FK_tbl_CartediCredito_CustomerTransactions] FOREIGN KEY ([FK_CustomerTransactionID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
ALTER TABLE [Snoopy].[tbl_CartediCredito] ADD CONSTRAINT [FK_tbl_CartediCredito_EuroTransactions] FOREIGN KEY ([FK_EuroTransactionID]) REFERENCES [Accounting].[tbl_EuroTransactions] ([TransactionID])
GO
ALTER TABLE [Snoopy].[tbl_CartediCredito] WITH NOCHECK ADD CONSTRAINT [FK_tbl_CartediCredito_IDDocuments] FOREIGN KEY ([FK_IDDocumentID]) REFERENCES [Snoopy].[tbl_IDDocuments] ([IDDocumentID])
GO
ALTER TABLE [Snoopy].[tbl_CartediCredito] WITH NOCHECK ADD CONSTRAINT [FK_tbl_CartediCredito_MovimentiGettoniGiocoEuro] FOREIGN KEY ([FK_MovimentoGettoniGiocoEuroID]) REFERENCES [Accounting].[tbl_MovimentiGettoniGiocoEuro] ([TransactionID])
GO
ALTER TABLE [Snoopy].[tbl_CartediCredito] WITH NOCHECK ADD CONSTRAINT [FK_tbl_CartediCredito_tbl_Contropartite] FOREIGN KEY ([FK_ContropartitaID]) REFERENCES [CasinoLayout].[tbl_Contropartite] ([ContropartitaID])
GO
