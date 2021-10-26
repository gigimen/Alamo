CREATE TABLE [GoldenClub].[tbl_InvitiCene]
(
[InvitoID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NOT NULL,
[GamingDate] [datetime] NOT NULL,
[conferma] [int] NULL,
[partecip] [int] NULL,
[Nota Gastro] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nota] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Manager] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_InvitiCene_InsertTimeStampUTC] DEFAULT (getutcdate()),
[SpedizioneSMSUTC] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [GoldenClub].[tbl_InvitiCene] ADD CONSTRAINT [PK_InvitiCene] PRIMARY KEY CLUSTERED  ([InvitoID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_InvitiCene_OnePerGamingDate] ON [GoldenClub].[tbl_InvitiCene] ([CustomerID], [GamingDate]) ON [PRIMARY]
GO
