SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [Snoopy].[vw_AllGiottoOrphanDocImages] 
AS 
--corretto il case
SELECT
	i.ImageID,
	i.OriginalSize,
	i.IDDocumentID
FROM [Giotto].Snoopy.ImmaginiDocumenti i
left outer join Snoopy.tbl_IDDocuments doc on doc.IDDocumentID = i.IDDocumentID
where doc.IDDocumentID is null
GO
