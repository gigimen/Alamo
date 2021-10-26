CREATE TABLE [Accounting].[tbl_DenaroTrovato]
(
[PK_DenaroTrovatoID] [int] NOT NULL IDENTITY(1, 1),
[FK_UserAccessID] [int] NOT NULL,
[GamingDate] [datetime] NOT NULL,
[TimeStampUTC] [datetime] NOT NULL,
[CHFCents] [int] NULL,
[EURCents] [int] NULL,
[LuogoRitrovo] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Osservazioni] [varchar] (150) COLLATE Latin1_General_CI_AS NULL,
[Trovatore] [varchar] (150) COLLATE Latin1_General_CI_AS NULL,
[DataControllo] [datetime] NULL,
[ImportiInf10] [bit] NOT NULL,
[InsertTimeStampUTC] [datetime] NULL CONSTRAINT [DF_tbl_DenaroTrovato_InsertTimeStampUTC] DEFAULT (getutcdate()),
[DataVersamento] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_DenaroTrovato] ADD CONSTRAINT [PK_Accounting_DenaroTrovato] PRIMARY KEY CLUSTERED  ([PK_DenaroTrovatoID]) ON [PRIMARY]
GO
ALTER TABLE [Accounting].[tbl_DenaroTrovato] ADD CONSTRAINT [FK_tbl_DenaroTrovato_tbl_UserAccesses] FOREIGN KEY ([FK_UserAccessID]) REFERENCES [FloorActivity].[tbl_UserAccesses] ([UserAccessID])
GO
