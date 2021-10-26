CREATE TABLE [Accounting].[tbl_CashlessTransactions]
(
[CashlessTransID] [int] NOT NULL IDENTITY(1, 1),
[CardNumber] [char] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LifeCycleID] [int] NOT NULL,
[ImportoCents] [int] NOT NULL,
[TransTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_CashlessTransactions] ADD CONSTRAINT [PK_CashlessTransaction2] PRIMARY KEY CLUSTERED  ([CashlessTransID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_CashlessTransactions] WITH NOCHECK ADD CONSTRAINT [FK_CashlessTransaction2_LifeCycles] FOREIGN KEY ([LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
