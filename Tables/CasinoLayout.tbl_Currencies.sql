CREATE TABLE [CasinoLayout].[tbl_Currencies]
(
[CurrencyID] [smallint] NOT NULL,
[IsoName] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExchangeRateMultiplier] [smallint] NOT NULL,
[BD0] [int] NOT NULL,
[CD0] [int] NULL,
[BD1] [int] NULL,
[CD1] [int] NULL,
[BD2] [int] NULL,
[CD2] [int] NULL,
[BD3] [int] NULL,
[CD3] [int] NULL,
[BD4] [int] NULL,
[CD4] [int] NULL,
[BD5] [int] NULL,
[CD5] [int] NULL,
[BD6] [int] NULL,
[CD6] [int] NULL,
[BD7] [int] NULL,
[CD7] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_Currencies] ADD CONSTRAINT [PK_tbl_Currencies] PRIMARY KEY CLUSTERED  ([CurrencyID]) ON [PRIMARY]
GO
