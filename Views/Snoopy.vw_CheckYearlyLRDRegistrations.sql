SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_CheckYearlyLRDRegistrations]
--WITH SCHEMABINDING
AS
SELECT
	m.CustomerID, 
	m.Firstname,
	m.Lastname,
	m.IdentificationID, 
	m.IdentificationGamingDate, 
	m.PDFID, 
	m.OriginalFileName, 
	m.PDFFileSize,
	m.GamingDate,
	r.MinImporto,
	r.MinGamingdate

FROM [Snoopy].[vw_MostRecentDoc] m
INNER JOIN 
(
	SELECT CustomerID,COUNT(*) AS Regs, MIN(r.Importo) AS MinImporto,MIN(r.GamingDate) AS MinGamingdate
	FROM snoopy.vw_AllRegistrations r
	WHERE r.Importo >= 4000 --reistrazione FORM III
	AND DATEPART(YEAR,r.GamingDate) = 2019
	GROUP BY CustomerID
)r ON r.CustomerID = m.CustomerID
GO
