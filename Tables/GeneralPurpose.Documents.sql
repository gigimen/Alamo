CREATE TABLE [GeneralPurpose].[Documents]
(
[DocumentID] [int] NOT NULL IDENTITY(1, 1),
[OriginalFileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FDescription] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginalFileSize] [int] NOT NULL,
[DocumentImage] [image] NOT NULL,
[UpdatedTimeStampUTC] [datetime] NOT NULL CONSTRAINT [DF_Documents_UpdatedTimeStampUTC] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [GeneralPurpose].[trg_UpdateDocumentTime] ON [GeneralPurpose].[Documents] 
AFTER UPDATE AS 
BEGIN

DECLARE @documentid INT
SELECT @documentid = [DocumentID]
FROM Inserted

UPDATE [GeneralPurpose].[Documents]
   SET [UpdatedTimeStampUTC] = GETUTCDATE()
 WHERE DocumentID = @documentid


END
GO
ALTER TABLE [GeneralPurpose].[Documents] ADD CONSTRAINT [PK_Documents] PRIMARY KEY CLUSTERED  ([DocumentID]) ON [PRIMARY]
GO
ALTER TABLE [GeneralPurpose].[Documents] ADD CONSTRAINT [IX_Documents] UNIQUE NONCLUSTERED  ([OriginalFileName]) ON [PRIMARY]
GO
