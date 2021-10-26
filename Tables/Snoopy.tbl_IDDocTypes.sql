CREATE TABLE [Snoopy].[tbl_IDDocTypes]
(
[IDDocTypeID] [int] NOT NULL IDENTITY(1, 1),
[FDescription] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NotForIdentification] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Snoopy].[tbl_IDDocTypes] ADD CONSTRAINT [PK_IDDocTypes] PRIMARY KEY CLUSTERED  ([IDDocTypeID]) ON [PRIMARY]
GO
