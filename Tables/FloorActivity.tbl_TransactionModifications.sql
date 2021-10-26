CREATE TABLE [FloorActivity].[tbl_TransactionModifications]
(
[ModID] [int] NOT NULL IDENTITY(1, 1),
[UserAccessID] [int] NOT NULL,
[ModDate] [datetime] NOT NULL CONSTRAINT [DF_TransactionModifications_ModDate] DEFAULT (getutcdate()),
[TransactionID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[FromQuantity] [int] NOT NULL,
[ToQuantity] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL,
[CashInbound] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_TransactionModifications] ADD CONSTRAINT [PK_TransactionModifications] PRIMARY KEY CLUSTERED  ([ModID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TransactionModifications_DenoIDTransIDInbound] ON [FloorActivity].[tbl_TransactionModifications] ([TransactionID], [DenoID], [CashInbound]) ON [PRIMARY]
GO
ALTER TABLE [FloorActivity].[tbl_TransactionModifications] ADD CONSTRAINT [FK_TransactionModifications_Denominations] FOREIGN KEY ([DenoID]) REFERENCES [CasinoLayout].[tbl_Denominations] ([DenoID])
GO
ALTER TABLE [FloorActivity].[tbl_TransactionModifications] ADD CONSTRAINT [FK_TransactionModifications_Transactions] FOREIGN KEY ([TransactionID]) REFERENCES [Accounting].[tbl_Transactions] ([TransactionID])
GO
ALTER TABLE [FloorActivity].[tbl_TransactionModifications] ADD CONSTRAINT [FK_TransactionModifications_UserAccesses] FOREIGN KEY ([UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
