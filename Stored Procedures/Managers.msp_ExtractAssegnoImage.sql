SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_ExtractAssegnoImage]
@AssegnoID INT,
@Path varchar(1024)
AS


DECLARE @ret int
SET @ret = 0


DECLARE @ImageData varbinary(max);
DECLARE @FullPathToOutputFile NVARCHAR(2048);

SELECT @ImageData = convert(varbinary(max), [ImageBin], 1),
@FullPathToOutputFile = @Path  + 'Assegno_' + CAST(@AssegnoID as varchar(32) ) + '.jpg'
FROM [Giotto].Accounting.[ImmaginiAssegni] WHERE [AssegnoID] = @AssegnoID

PRINT @FullPathToOutputFile
EXEC @ret = Managers.msp_ExtractImage @ImageData,@FullPathToOutputFile


RETURN @ret
GO
