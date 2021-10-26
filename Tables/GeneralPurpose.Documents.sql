CREATE TABLE [GeneralPurpose].[Documents]
(
[DocumentID] [int] NOT NULL IDENTITY(1, 1),
[OriginalFileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalFileSize] [int] NOT NULL,
[DocumentImage] [image] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [GeneralPurpose].[Documents] ADD CONSTRAINT [PK_Documents] PRIMARY KEY CLUSTERED  ([DocumentID]) ON [PRIMARY]
GO
ALTER TABLE [GeneralPurpose].[Documents] ADD CONSTRAINT [IX_Documents] UNIQUE NONCLUSTERED  ([OriginalFileName]) ON [PRIMARY]
GO
