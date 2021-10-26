SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Accounting].[vw_AllGiottoAssegniImages] 
AS 

--corretto i lcase

SELECT
	i.AssegnoID,
	i.InsertTimeStampUTC,
	[GeneralPurpose].[fn_UTCToLocal](1,i.InsertTimeStampUTC) AS InsertTimeStampLoc,
	i.OriginalSize,
	d.GamingDate,
	d.CustomerID,
	d.FirstName,
	d.LastName,
	d.BirthDate,
	d.IDDocumentID
FROM [Giotto].Accounting.ImmaginiAssegni i
LEFT OUTER JOIN Snoopy.vw_AllAssegni d
ON i.AssegnoID = d.AssegnoID
GO
