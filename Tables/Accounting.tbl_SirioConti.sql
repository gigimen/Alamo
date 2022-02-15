CREATE TABLE [Accounting].[tbl_SirioConti]
(
[conto] [varchar] (32) COLLATE Latin1_General_CI_AS NOT NULL,
[indice] [int] NOT NULL,
[CurrencyID] [int] NOT NULL,
[giustif] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[descr] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Cco] [nvarchar] (50) COLLATE Latin1_General_CI_AS NULL,
[esistenzacco] [int] NULL,
[data] [int] NULL,
[inverti] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_SirioConti] ADD CONSTRAINT [PK_tbl_SirioConti] PRIMARY KEY CLUSTERED ([conto], [indice]) ON [PRIMARY]
GO
