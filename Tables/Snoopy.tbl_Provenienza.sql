CREATE TABLE [Snoopy].[tbl_Provenienza]
(
[ProvenienzaID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_Provenienza] ADD CONSTRAINT [PK_Provenienza] PRIMARY KEY CLUSTERED  ([ProvenienzaID]) ON [PRIMARY]
GO
