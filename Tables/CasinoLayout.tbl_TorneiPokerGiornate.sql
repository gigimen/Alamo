CREATE TABLE [CasinoLayout].[tbl_TorneiPokerGiornate]
(
[PK_TPGiornataID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[FK_TorneoID] [int] NOT NULL,
[GamingDate] [datetime] NOT NULL,
[FK_DayTypeID] [int] NOT NULL,
[TaxCents] [int] NULL,
[BuyInCents] [int] NULL,
[NGarantiti] [int] NULL,
[NRientri] [int] NULL,
[EnableVincita] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_TorneiPokerGiornate] ADD CONSTRAINT [PK_tbl_TorneiPokerGiornate] PRIMARY KEY CLUSTERED  ([PK_TPGiornataID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbl_TorneiPokerGiornate_By_Gamingdate] ON [CasinoLayout].[tbl_TorneiPokerGiornate] ([GamingDate]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tbl_TorneiPokerGiornate_GamingDate] ON [CasinoLayout].[tbl_TorneiPokerGiornate] ([GamingDate], [FK_TorneoID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_TorneiPokerGiornate] ADD CONSTRAINT [FK_tbl_TorneiPokerGiornate_tbl_TorneiPoker] FOREIGN KEY ([FK_TorneoID]) REFERENCES [CasinoLayout].[tbl_TorneiPoker] ([PK_TorneoID])
GO
ALTER TABLE [CasinoLayout].[tbl_TorneiPokerGiornate] ADD CONSTRAINT [FK_tbl_TorneiPokerGiornate_tbl_TorneoPokerDayType] FOREIGN KEY ([FK_DayTypeID]) REFERENCES [CasinoLayout].[tbl_TorneoPokerDayType] ([PK_DayTypeID])
GO
