CREATE TABLE [Accounting].[tbl_Rettifica_Restituzione]
(
[PK_RettificaRestituzioneID] [int] NOT NULL IDENTITY(1, 1),
[FK_UserAccessID] [int] NOT NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_tbl_Rettifica_Restituzione_InsertTimeStampUTC] DEFAULT (getutcdate()),
[GamingDate] [datetime] NOT NULL,
[FK_StockID] [int] NOT NULL,
[EURCents] [int] NULL,
[CHFCents] [int] NULL,
[Descrizione] [varchar] (512) COLLATE Latin1_General_CI_AS NULL,
[OraErroreUTC] [datetime] NOT NULL,
[FK_RespID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Rettifica_Restituzione] ADD CONSTRAINT [CK_tbl_Rettifica_Restituzione_AmountCheck] CHECK (([EURCents] IS NOT NULL OR [CHFCents] IS NOT NULL))
GO
ALTER TABLE [Accounting].[tbl_Rettifica_Restituzione] ADD CONSTRAINT [PK_tbl_Rettifica_Restituzione] PRIMARY KEY CLUSTERED  ([PK_RettificaRestituzioneID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbl_Rettifica_Restituzione_StockID_GamingDate] ON [Accounting].[tbl_Rettifica_Restituzione] ([GamingDate], [FK_StockID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_Rettifica_Restituzione] ADD CONSTRAINT [FK_tbl_Rettifica_Restituzione_Stocks] FOREIGN KEY ([FK_StockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
ALTER TABLE [Accounting].[tbl_Rettifica_Restituzione] ADD CONSTRAINT [FK_tbl_Rettifica_Restituzione_Users] FOREIGN KEY ([FK_RespID]) REFERENCES [CasinoLayout].[Users] ([UserID])
GO
