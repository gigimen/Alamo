SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [Snoopy].[vw_AllPepChecksOfTheYear]
--WITH SCHEMABINDING
AS
SELECT  p.PepCheckID, 
	p.PDFFileSize, 
	p.PDFfile, 
	p.PepCheckYear ,
	p.OraPepCheck,
	p.CustomerID, 
	p.IdentificationID, 
	p.IdentificationGamingDate,
	p.InsertUserInitials
FROM  Snoopy.vw_AllPepChecks p
where p.PepCheckYear = DatePart(yy,GetDate())




GO
