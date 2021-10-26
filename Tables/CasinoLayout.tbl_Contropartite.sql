CREATE TABLE [CasinoLayout].[tbl_Contropartite]
(
[ContropartitaID] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FK_CashIn_IDCauseID] [int] NULL,
[FK_CashOut_IDCauseID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_Contropartite] ADD CONSTRAINT [PK_tbl_Contropartite] PRIMARY KEY CLUSTERED  ([ContropartitaID]) ON [PRIMARY]
GO
