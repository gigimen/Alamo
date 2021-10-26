CREATE TABLE [Snoopy].[tbl_Assegni]
(
[PK_AssegnoID] [int] NOT NULL IDENTITY(1, 1),
[FK_BankAccountID] [int] NOT NULL,
[FK_IDDocumentID] [int] NULL,
[FK_EmissCustTransID] [int] NOT NULL,
[FK_RedemCustTransID] [int] NULL,
[FK_ContropartitaID] [int] NOT NULL,
[NrAssegno] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CentaxCode] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Commissione] [float] NOT NULL CONSTRAINT [DF_tbl_Assegni_Commissione] DEFAULT ((0)),
[CreditiGiocoRate] [float] NOT NULL CONSTRAINT [DF_tbl_Assegni_CreditiGiocoRate] DEFAULT ((1)),
[FK_ControlUserAccessID] [int] NULL,
[ControlTimeStampUTC] [datetime] NULL,
[ControlDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Assegni] ADD CONSTRAINT [PK_tbl_Assegni] PRIMARY KEY CLUSTERED  ([PK_AssegnoID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Assegni] WITH NOCHECK ADD CONSTRAINT [FK_tbl_Assegni_Contropartita] FOREIGN KEY ([FK_ContropartitaID]) REFERENCES [CasinoLayout].[tbl_Contropartite] ([ContropartitaID])
GO
ALTER TABLE [Snoopy].[tbl_Assegni] WITH NOCHECK ADD CONSTRAINT [FK_tbl_Assegni_CustomerBankAccounts] FOREIGN KEY ([FK_BankAccountID]) REFERENCES [Snoopy].[tbl_CustomerBankAccounts] ([BankAccountID])
GO
ALTER TABLE [Snoopy].[tbl_Assegni] WITH NOCHECK ADD CONSTRAINT [FK_tbl_Assegni_CustomerTransactions] FOREIGN KEY ([FK_RedemCustTransID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
ALTER TABLE [Snoopy].[tbl_Assegni] ADD CONSTRAINT [FK_tbl_Assegni_EmissCustomerTransactions] FOREIGN KEY ([FK_EmissCustTransID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
ALTER TABLE [Snoopy].[tbl_Assegni] WITH NOCHECK ADD CONSTRAINT [FK_tbl_Assegni_IDDocuments] FOREIGN KEY ([FK_IDDocumentID]) REFERENCES [Snoopy].[tbl_IDDocuments] ([IDDocumentID])
GO
