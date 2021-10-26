CREATE TABLE [Accounting].[tbl_TicketTransactions]
(
[TicketTransID] [int] NOT NULL IDENTITY(1, 1),
[TicketNumber] [bigint] NOT NULL,
[LifeCycleID] [int] NOT NULL,
[AmountCents] [int] NOT NULL,
[TransTimeUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_TicketTransactions_TransTimeUTC] DEFAULT (getutcdate()),
[IsVoided] [bit] NOT NULL CONSTRAINT [DF_tbl_TicketTransactions_IsVoided] DEFAULT ((0)),
[IsPromo] [bit] NOT NULL,
[IsSfr] [bit] NOT NULL,
[IssueLocation] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssueTimeUTC] [datetime] NULL,
[IsDRGT] [bit] NOT NULL CONSTRAINT [DF_tbl_TicketTransactions_IsDRGT] DEFAULT ((1)),
[FK_SiteID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_TicketTransactions] ADD CONSTRAINT [PK_TicketTransaction2] PRIMARY KEY CLUSTERED  ([TicketTransID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TicketTransactions_ISDRGT] ON [Accounting].[tbl_TicketTransactions] ([IsDRGT]) INCLUDE ([AmountCents], [LifeCycleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TicketTransactions_Voided] ON [Accounting].[tbl_TicketTransactions] ([IsVoided], [AmountCents]) INCLUDE ([IsDRGT], [IsPromo], [IsSfr], [LifeCycleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TicketTransactions_IsPromo] ON [Accounting].[tbl_TicketTransactions] ([IsVoided], [IsPromo]) INCLUDE ([AmountCents], [IsSfr], [IssueLocation], [IssueTimeUTC], [LifeCycleID], [TicketNumber], [TicketTransID], [TransTimeUTC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TicketTransactions_LifeCycleID_IsDRGT] ON [Accounting].[tbl_TicketTransactions] ([LifeCycleID], [IsDRGT]) INCLUDE ([AmountCents]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_TicketTransactions] ADD CONSTRAINT [FK_tbl_TicketTransactions_Sites] FOREIGN KEY ([FK_SiteID]) REFERENCES [CasinoLayout].[Sites] ([SiteID])
GO
ALTER TABLE [Accounting].[tbl_TicketTransactions] WITH NOCHECK ADD CONSTRAINT [FK_TicketTransaction_LifeCycles] FOREIGN KEY ([LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
