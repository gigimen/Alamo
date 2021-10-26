CREATE TABLE [FloorActivity].[tbl_CustomerTransactionModifications]
(
[ModID] [int] NOT NULL IDENTITY(1, 1),
[UserAccessID] [int] NOT NULL,
[ModDate] [datetime] NOT NULL CONSTRAINT [DF_CustomerTransactionModifications_ModDate] DEFAULT (getutcdate()),
[CustomerTransactionID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[FromQuantity] [int] NOT NULL,
[ToQuantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL,
[CashInbound] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_CustomerTransactionModifications] ADD CONSTRAINT [PK_CustomerTransactionModifications] PRIMARY KEY CLUSTERED  ([ModID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerTransactionModifications] ON [FloorActivity].[tbl_CustomerTransactionModifications] ([CustomerTransactionID], [DenoID], [CashInbound]) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_CustomerTransactionModifications] ADD CONSTRAINT [FK_CustomerTransactionModifications_CustomerTransactions] FOREIGN KEY ([CustomerTransactionID]) REFERENCES [Snoopy].[tbl_CustomerTransactions] ([CustomerTransactionID])
GO
ALTER TABLE [FloorActivity].[tbl_CustomerTransactionModifications] ADD CONSTRAINT [FK_CustomerTransactionModifications_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [FloorActivity].[tbl_CustomerTransactionModifications] ADD CONSTRAINT [FK_CustomerTransactionModifications_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
