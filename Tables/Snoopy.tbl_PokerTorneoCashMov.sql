CREATE TABLE [Snoopy].[tbl_PokerTorneoCashMov]
(
[PK_MovID] [int] NOT NULL IDENTITY(1, 1),
[FK_TPGiornataID] [int] NOT NULL,
[FK_LIfeCyleID] [int] NOT NULL,
[MoveType] [int] NOT NULL,
[TimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_PokerTorneoCashMov_TimeStampUTC] DEFAULT (getutcdate()),
[AmountCents] [int] NOT NULL,
[FK_CustomerID] [int] NOT NULL,
[FK_UserAccessID] [int] NOT NULL,
[Progressivo] [int] NOT NULL,
[CancelID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_PokerTorneoCashMov] WITH NOCHECK ADD CONSTRAINT [CK_CheckTorneoMoveType] CHECK (([Snoopy].[fn_TorneoCheckMoveType]([movetype],[FK_TPGiornataID])<=(1)))
GO
ALTER TABLE [Snoopy].[tbl_PokerTorneoCashMov] ADD CONSTRAINT [PK_tbl_PokerTorneoCashMov] PRIMARY KEY CLUSTERED  ([PK_MovID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbl_PokerTorneoCashMovProgressivo] ON [Snoopy].[tbl_PokerTorneoCashMov] ([FK_TPGiornataID], [Progressivo]) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_PokerTorneoCashMov] ADD CONSTRAINT [FK_tbl_PokerTorneoCashMov_tbl_Cancellations] FOREIGN KEY ([CancelID]) REFERENCES [FloorActivity].[tbl_Cancellations] ([CancelID])
GO
ALTER TABLE [Snoopy].[tbl_PokerTorneoCashMov] ADD CONSTRAINT [FK_tbl_PokerTorneoCashMov_tbl_Customers] FOREIGN KEY ([FK_CustomerID]) REFERENCES [Snoopy].[tbl_Customers] ([CustomerID])
GO
ALTER TABLE [Snoopy].[tbl_PokerTorneoCashMov] ADD CONSTRAINT [FK_tbl_PokerTorneoCashMov_tbl_LifeCycles] FOREIGN KEY ([FK_LIfeCyleID]) REFERENCES [Accounting].[tbl_LifeCycles] ([LifeCycleID])
GO
ALTER TABLE [Snoopy].[tbl_PokerTorneoCashMov] ADD CONSTRAINT [FK_tbl_PokerTorneoCashMov_tbl_TorneiPokerGiornate] FOREIGN KEY ([FK_TPGiornataID]) REFERENCES [CasinoLayout].[tbl_TorneiPokerGiornate] ([PK_TPGiornataID])
GO
ALTER TABLE [Snoopy].[tbl_PokerTorneoCashMov] ADD CONSTRAINT [FK_tbl_PokerTorneoCashMov_tbl_UserAccesses] FOREIGN KEY ([FK_UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'0= BuyIn,1=Rotto,2=Vincita', 'SCHEMA', N'Snoopy', 'TABLE', N'tbl_PokerTorneoCashMov', 'COLUMN', N'MoveType'
GO
