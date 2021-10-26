CREATE TABLE [Snoopy].[tbl_FasceEta]
(
[FasciaEtaID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_FasceEta] ADD CONSTRAINT [PK_FasceEta] PRIMARY KEY CLUSTERED  ([FasciaEtaID]) ON [PRIMARY]
GO
