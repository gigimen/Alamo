SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE [Managers].[msp_ExtractLastDocImages]
AS

DECLARE @RC int
DECLARE @Docid int
DECLARE @Path varchar(1024)

-- TODO: Set parameter values here.
SET @Path = 'L:\images\'
SELECT @Docid = MAX([IDDocumentID]) ---get lat image inserted
FROM [Giotto].[Snoopy].[ImmaginiDocumenti]

EXECUTE @RC = [Managers].[msp_ExtractDocImages] 
   @Docid
  ,@Path


SELECT @RC AS RC

DECLARE @AssegnoID int

SELECT @AssegnoID = MAX(AssegnoID) ---get last image inserted
FROM [Giotto].Accounting.[ImmaginiAssegni]

EXECUTE @RC = [Managers].[msp_ExtractAssegnoImage] 
   @AssegnoID
  ,@Path
GO
