CREATE TABLE [Accounting].[tbl_SlotTransactions]
(
[SlotTransactionID] [int] NOT NULL IDENTITY(1, 1),
[SlotNr] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_SlotTransactions_InsertTimeStampUTC] DEFAULT (getutcdate()),
[OpTypeID] [int] NOT NULL,
[AmountCents] [int] NOT NULL,
[LifeCycleID] [int] NULL,
[JackpotID] [int] NULL,
[JpInstance] [int] NULL,
[PinCode] [int] NULL,
[InterventoID] [int] NULL,
[PaymentTimeUTC] [datetime] NULL,
[CancelID] [int] NULL,
[IpAddr] [int] NULL,
[Currency] [smallint] NOT NULL CONSTRAINT [DF_tbl_SlotTransactions_Currency] DEFAULT ((4)),
[ValidationNumber] [bigint] NULL,
[ExchangeRate] [float] NULL,
[JpID] [varchar] (4) COLLATE Latin1_General_CI_AS NULL,
[JpName] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Nota] [varchar] (1024) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_SlotTransactions] ADD CONSTRAINT [CK_tbl_SlotTransactions] CHECK (([OpTypeID]=(17) OR [OpTypeID]=(16) OR [OpTypeID]=(15)))
GO
ALTER TABLE [Accounting].[tbl_SlotTransactions] ADD CONSTRAINT [CK_tbl_SlotTransactions_SlotNr] CHECK (([SlotNr]>(0)))
GO
ALTER TABLE [Accounting].[tbl_SlotTransactions] ADD CONSTRAINT [PK_tbl_SlotTransactions] PRIMARY KEY CLUSTERED  ([SlotTransactionID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_SlotTransactions] ADD CONSTRAINT [FK_tbl_SlotTransactions_OperationTypes] FOREIGN KEY ([OpTypeID]) REFERENCES [CasinoLayout].[OperationTypes] ([OpTypeID])
GO
ALTER TABLE [Accounting].[tbl_SlotTransactions] ADD CONSTRAINT [FK_tbl_SlotTransactions_Rimborsi] FOREIGN KEY ([InterventoID]) REFERENCES [Techs].[Rimborsi] ([InterventoID])
GO
GRANT DELETE ON  [Accounting].[tbl_SlotTransactions] TO [TecRole]
GO
GRANT INSERT ON  [Accounting].[tbl_SlotTransactions] TO [TecRole]
GO
GRANT SELECT ON  [Accounting].[tbl_SlotTransactions] TO [TecRole]
GO
GRANT UPDATE ON  [Accounting].[tbl_SlotTransactions] TO [TecRole]
GO
EXEC sp_addextendedproperty N'MS_Description', N'solo jackpot, handpay e shortpay', 'SCHEMA', N'Accounting', 'TABLE', N'tbl_SlotTransactions', 'CONSTRAINT', N'CK_tbl_SlotTransactions'
GO
EXEC sp_addextendedproperty N'MS_Description', N'SlotNr must be postive and less than 1000', 'SCHEMA', N'Accounting', 'TABLE', N'tbl_SlotTransactions', 'CONSTRAINT', N'CK_tbl_SlotTransactions_SlotNr'
GO
