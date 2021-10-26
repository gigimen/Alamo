CREATE TABLE [Accounting].[tbl_EuroTransactions]
(
[TransactionID] [int] NOT NULL IDENTITY(1, 1),
[LifeCycleID] [int] NOT NULL,
[OpTypeID] [int] NOT NULL,
[InsertTimestamp] [datetime] NOT NULL CONSTRAINT [DF_EuroTransactions_InsertTimestamp] DEFAULT (getutcdate()),
[ImportoEuroCents] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL,
[RedeemTransactionID] [int] NULL,
[CustomerID] [int] NULL,
[CancelID] [int] NULL,
[FrancsInRedemCents] [int] NULL,
[PhysicalEuros] [bit] NOT NULL CONSTRAINT [DF_EuroTransactions_PhysicalEuros] DEFAULT ((1)),
[LeftToBeRedeemedCents] [int] NULL,
[UserAccessID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_EuroTransactions] ADD CONSTRAINT [PK_EuroTransactions] PRIMARY KEY CLUSTERED  ([TransactionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EuroTransactions_By_CustomeID] ON [Accounting].[tbl_EuroTransactions] ([CustomerID], [CancelID]) INCLUDE ([ExchangeRate], [FrancsInRedemCents], [ImportoEuroCents], [InsertTimestamp], [LeftToBeRedeemedCents], [LifeCycleID], [OpTypeID], [PhysicalEuros], [RedeemTransactionID], [TransactionID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_EuroTransactions] ADD CONSTRAINT [FK_EuroTransactions_CancelActions] FOREIGN KEY ([CancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [Accounting].[tbl_EuroTransactions] ADD CONSTRAINT [FK_EuroTransactions_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Accounting].[tbl_EuroTransactions] ADD CONSTRAINT [FK_EuroTransactions_EuroTransactions] FOREIGN KEY ([RedeemTransactionID]) REFERENCES [Accounting].[tbl_EuroTransactions] ([TransactionID])
GO
ALTER TABLE [Accounting].[tbl_EuroTransactions] ADD CONSTRAINT [FK_EuroTransactions_LifeCycles] FOREIGN KEY ([LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Accounting].[tbl_EuroTransactions] ADD CONSTRAINT [FK_EuroTransactions_OperationTypes] FOREIGN KEY ([OpTypeID]) REFERENCES [CasinoLayout].[OperationTypes] ([OpTypeID])
GO
ALTER TABLE [Accounting].[tbl_EuroTransactions] ADD CONSTRAINT [FK_EuroTransactions_UserAccess] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
