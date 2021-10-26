SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [Snoopy].[vw_AllGiottoDocImages] 
AS 

--corretto il case
SELECT
	i.ImageID,
	i.OriginalSize,
	i.IDDocumentID,
	i.PageNr,
	i.InsertTimeStampUTC,
	[GeneralPurpose].[fn_UTCToLocal](1,i.InsertTimeStampUTC) AS InsertTimeStampLoc,
	isnull(d.CustomerID,0) as CustomerID,
	isnull (d.FirstName,'??') as FirstName,
	isnull (d.LastName,'??') as LastName,
	isnull (d.BirthDate,'1.1.1900') as BirthDate,
	isnull (d.DocExpired,0) as DocExpired,
	isnull (d.ExpirationDate,'1.1.1900') AS ExpirationDate,
	isnull (d.UsedForIdentification,0) as UsedForIdentification
FROM [Giotto].Snoopy.ImmaginiDocumenti i
left outer join Snoopy.vw_AllCustomerIDDocuments d
on i.IDDocumentID = d.IDDocumentID
GO
