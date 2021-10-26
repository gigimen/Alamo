SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_ExtractDocImages]
@Docid INT,
@Path varchar(1024)
AS


DECLARE @ret int
SET @ret = 0

DECLARE CURSOR_ImagesIds CURSOR FOR (
	SELECT i.[ImageID] FROM [Giotto].[Snoopy].[ImmaginiDocumenti] i
	WHERE i.[IDDocumentID] = @Docid
	)


DECLARE @ImageId INT;
DECLARE @ImageData varbinary(max);
DECLARE @FullPathToOutputFile NVARCHAR(2048);

OPEN CURSOR_ImagesIds

FETCH NEXT FROM CURSOR_ImagesIds INTO @ImageId
WHILE (@@FETCH_STATUS <> -1 AND @ret = 0)
BEGIN
  SELECT @ImageData = (SELECT convert(varbinary(max), [ImageBin], 1) FROM [Giotto].[Snoopy].[ImmaginiDocumenti] WHERE [ImageID] = @ImageId);
  SELECT 
	@FullPathToOutputFile = @Path  + 'Document_' + 
	CAST(IDDocumentID as varchar(32) ) + '_' +
	CAST([PageNr] as varchar(32) ) + '.jpg'
	FROM [Giotto].[Snoopy].[ImmaginiDocumenti] WHERE [ImageID] = @ImageId

	PRINT @FullPathToOutputFile
	EXEC @ret = Managers.msp_ExtractImage @ImageData,@FullPathToOutputFile

  FETCH NEXT FROM CURSOR_ImagesIds INTO @ImageId
END
CLOSE CURSOR_ImagesIds
DEALLOCATE CURSOR_ImagesIds


RETURN @ret
GO
