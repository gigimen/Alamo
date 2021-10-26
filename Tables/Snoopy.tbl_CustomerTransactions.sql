CREATE TABLE [Snoopy].[tbl_CustomerTransactions]
(
[CustomerTransactionID] [int] NOT NULL IDENTITY(1, 1),
[CustomerTransactionTime] [datetime] NOT NULL,
[SourceLifeCycleID] [int] NOT NULL,
[CustomerID] [int] NOT NULL,
[UserAccessID] [int] NOT NULL,
[CustTrCancelID] [int] NULL,
[OpTypeID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactions] ADD CONSTRAINT [PK_CustomerTransactions] PRIMARY KEY CLUSTERED  ([CustomerTransactionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerTransactions_CustTrCancelID] ON [Snoopy].[tbl_CustomerTransactions] ([CustTrCancelID]) INCLUDE ([CustomerID], [CustomerTransactionID], [CustomerTransactionTime], [SourceLifeCycleID]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactions] WITH NOCHECK ADD CONSTRAINT [FK_CustomerTransactions_CancelActions] FOREIGN KEY ([CustTrCancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactions] WITH NOCHECK ADD CONSTRAINT [FK_CustomerTransactions_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactions] ADD CONSTRAINT [FK_CustomerTransactions_LifeCycles] FOREIGN KEY ([SourceLifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactions] ADD CONSTRAINT [FK_CustomerTransactions_OperationTypes] FOREIGN KEY ([OpTypeID]) REFERENCES [CasinoLayout].[OperationTypes] ([OpTypeID])
GO
ALTER TABLE [Snoopy].[tbl_CustomerTransactions] WITH NOCHECK ADD CONSTRAINT [FK_CustomerTransactions_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
