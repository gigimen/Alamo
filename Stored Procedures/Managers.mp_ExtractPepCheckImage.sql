SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Managers].[mp_ExtractPepCheckImage]
@PepcheckID INT,
@Path VARCHAR(1024)
AS


DECLARE @ret INT
SET @ret = 0


DECLARE @ImageData VARBINARY(MAX);
DECLARE @FullPathToOutputFile NVARCHAR(2048)
SELECT @ImageData = convert(varbinary(max), [PDFfile], 1),
@FullPathToOutputFile = @Path  + 'PepCheck_' + CAST(@PepcheckID as varchar(32) ) + '.pdf'
FROM [Giotto].[Snoopy].[PepChecks] WHERE [PepCheckID] = @PepcheckID

PRINT @FullPathToOutputFile
EXEC @ret = Managers.msp_ExtractImage @ImageData,@FullPathToOutputFile


RETURN @ret
GO
