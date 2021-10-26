CREATE TABLE [ForIncasso].[tbl_tmpBSELiveGame]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[Tag] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrencyID] [int] NOT NULL,
[GamingDate] [smalldatetime] NOT NULL,
[Fills] [float] NOT NULL,
[Credits] [float] NOT NULL,
[EstimatedDrop] [float] NOT NULL,
[CashBox] [float] NOT NULL,
[Apertura] [float] NOT NULL,
[Chiusura] [float] NOT NULL,
[Tronc] [float] NOT NULL,
[CurrencyRate] [float] NOT NULL,
[LucyChipsPezzi] [int] NULL,
[BSE_CHF] AS (CONVERT([float],((([Chiusura]-[Apertura])+[Credits])-[Fills])+[CashBox],(0))*[CurrencyRate]),
[CashBox_CHF] AS (CONVERT([float],[cashbox],(0))*[CurrencyRate])
) ON [PRIMARY]
GO
ALTER TABLE [ForIncasso].[tbl_tmpBSELiveGame] ADD CONSTRAINT [PK_tbl_BSELiveGame] PRIMARY KEY CLUSTERED  ([id]) ON [PRIMARY]
GO
