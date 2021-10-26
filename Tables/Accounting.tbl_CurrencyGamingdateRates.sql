CREATE TABLE [Accounting].[tbl_CurrencyGamingdateRates]
(
[GamingDate] [smalldatetime] NOT NULL,
[CurrencyID] [smallint] NOT NULL,
[IntRate] [float] NOT NULL,
[ExtRate] [float] NULL,
[TableRate] [float] NULL,
[InsertUserAccessID] [int] NULL,
[InsertTime] [datetime] NULL,
[FixedUserAccessID] [int] NULL,
[FixedTime] [datetime] NULL,
[Sold] [tinyint] NULL,
[SellingRate] [float] NULL,
[Note] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_CurrencyGamingdateRates] ADD CONSTRAINT [PK_tbl_CurrencyGamingdateRates] PRIMARY KEY CLUSTERED  ([GamingDate], [CurrencyID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_CurrencyGamingdateRates] ADD CONSTRAINT [FK_tbl_CurrencyGamingdateRates_Currencies] FOREIGN KEY ([CurrencyID]) REFERENCES [CasinoLayout].[tbl_Currencies] ([CurrencyID])
GO
ALTER TABLE [Accounting].[tbl_CurrencyGamingdateRates] WITH NOCHECK ADD CONSTRAINT [FK_tbl_CurrencyGamingdateRates_FixedUserAccesses] FOREIGN KEY ([FixedUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [Accounting].[tbl_CurrencyGamingdateRates] WITH NOCHECK ADD CONSTRAINT [FK_tbl_CurrencyGamingdateRates_InsertUserAccesses] FOREIGN KEY ([InsertUserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
ALTER TABLE [Accounting].[tbl_CurrencyGamingdateRates] NOCHECK CONSTRAINT [FK_tbl_CurrencyGamingdateRates_FixedUserAccesses]
GO
ALTER TABLE [Accounting].[tbl_CurrencyGamingdateRates] NOCHECK CONSTRAINT [FK_tbl_CurrencyGamingdateRates_InsertUserAccesses]
GO
