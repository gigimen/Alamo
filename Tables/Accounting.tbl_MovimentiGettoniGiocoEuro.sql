CREATE TABLE [Accounting].[tbl_MovimentiGettoniGiocoEuro]
(
[TransactionID] [int] NOT NULL IDENTITY(1, 1),
[LifeCycleID] [int] NOT NULL,
[DenoID] [int] NOT NULL,
[TotGettoni] [int] NOT NULL,
[ExchangeRate] [float] NOT NULL,
[ExchangeTimeUTC] [datetime] NOT NULL,
[CausaleID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_MovimentiGettoniGiocoEuro] ADD CONSTRAINT [CK_tbl_DenosExchanges] CHECK (([DenoID]=(182) OR [DenoID]=(183)))
GO
ALTER TABLE [Accounting].[tbl_MovimentiGettoniGiocoEuro] ADD CONSTRAINT [CK_tbl_DenosExchanges_Causale] CHECK (([CausaleID]=(4) OR [CausaleID]=(3) OR [CausaleID]=(2) OR [CausaleID]=(1)))
GO
ALTER TABLE [Accounting].[tbl_MovimentiGettoniGiocoEuro] ADD CONSTRAINT [PK_tbl_DenosExchanges] PRIMARY KEY CLUSTERED  ([TransactionID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_MovimentiGettoniGiocoEuro] ADD CONSTRAINT [FK_tbl_DenosExchanges_LifeCycles] FOREIGN KEY ([LifeCycleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'1=Acquisto gettoni € con cash €,2=Riscossione gettoni €,3=Acquisto gettoni € con Carta di credito,4=Acquisto gettoni € con Assegno', 'SCHEMA', N'Accounting', 'TABLE', N'tbl_MovimentiGettoniGiocoEuro', 'COLUMN', N'TransactionID'
GO
