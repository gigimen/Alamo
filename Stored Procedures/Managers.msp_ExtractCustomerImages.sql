SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_ExtractCustomerImages]
@custid INT,
@Path varchar(1024)
AS

DECLARE @Filename NVARCHAR(1024);
SELECT @Filename = LastName FROM Snoopy.tbl_Customers WHERE CustomerID = @custid
if @Filename is null --customer does not exists anymore in Alamo
begin
	raiserror('Invalid CustID %d specified',16,1,@custid)
	return 1
end

DECLARE @ret int
SET @ret = 0

DECLARE CURSOR_ImagesIds CURSOR FOR (
	SELECT i.[ImageID] FROM [Giotto].Snoopy.[ImmaginiDocumenti] i
	INNER JOIN Snoopy.tbl_IDDocuments d ON d.IDDocumentID = i.IDDocumentID
	WHERE d.CustomerID = @custid
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
	@FullPathToOutputFile = @Path  + @Filename + '_' + 
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
