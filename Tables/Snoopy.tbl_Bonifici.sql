CREATE TABLE [Snoopy].[tbl_Bonifici]
(
[BonificoID] [int] NOT NULL IDENTITY(2014, 7),
[BankAccountID] [int] NOT NULL,
[OrderCustTransID] [int] NOT NULL,
[IDDocumentID] [int] NULL,
[ExecTimeStampUTC] [datetime] NULL,
[ExecUserAccessID] [int] NULL,
[IsFromEuroCredits] [bit] NOT NULL CONSTRAINT [DF_Bonifici_IsFromEuroCredits] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Bonifici] ADD CONSTRAINT [PK_Bonifici] PRIMARY KEY CLUSTERED  ([BonificoID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Bonifici] WITH NOCHECK ADD CONSTRAINT [FK_Bonifici_CustomerBankAccounts] FOREIGN KEY ([BankAccountID]) REFERENCES [Snoopy].[tbl_CustomerBankAccounts] ([BankAccountID])
GO
ALTER TABLE [Snoopy].[tbl_Bonifici] WITH NOCHECK ADD CONSTRAINT [FK_Bonifici_IDDocuments] FOREIGN KEY ([IDDocumentID]) REFERENCES [Snoopy].[tbl_IDDocuments] ([IDDocumentID])
GO
ALTER TABLE [Snoopy].[tbl_Bonifici] WITH NOCHECK ADD CONSTRAINT [FK_Bonifici_OrderCustTrans] FOREIGN KEY ([OrderCustTransID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
