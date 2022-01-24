SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [GeneralPurpose].[vw_AllDocuments]
AS
SELECT [DocumentID]
      ,[OriginalFileName]
      ,[FDescription]
      ,[OriginalFileSize]
      ,[DocumentImage]
      ,GeneralPurpose.fn_UTCToLocal(1,[UpdatedTimeStampUTC]) AS LastUpdated
  FROM [GeneralPurpose].[Documents]

GO
