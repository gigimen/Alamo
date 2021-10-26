CREATE TABLE [Snoopy].[tbl_Depositi]
(
[DepositoID] [int] NOT NULL IDENTITY(1, 1),
[DepoCustTransID] [int] NOT NULL,
[PrelevCustTransID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Depositi] ADD CONSTRAINT [PK_Depositi] PRIMARY KEY CLUSTERED  ([DepositoID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Depositi_DepoCustTransID] ON [Snoopy].[tbl_Depositi] ([DepoCustTransID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Depositi] WITH NOCHECK ADD CONSTRAINT [FK_Depositi_EmissionCustTrans] FOREIGN KEY ([DepoCustTransID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
ALTER TABLE [Snoopy].[tbl_Depositi] WITH NOCHECK ADD CONSTRAINT [FK_Depositi_RedemptionCustTransaction] FOREIGN KEY ([PrelevCustTransID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
