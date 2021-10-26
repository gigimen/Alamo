SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Snoopy].[vw_MostRecentDoc]
--WITH SCHEMABINDING
AS
SELECT
	c.CustomerID, 
	c.Firstname,
	c.Lastname,
	c.BirthDate,
	c.IdentificationID, 
	c.IdentificationGamingDate, 
	p.PDFID, 
	p.OriginalFileName, 
	pg.PDFFileSize, 
	p.InsertUserAccessID,
    UPPER(LEFT(u.FirstName,1)) + UPPER(LEFT(u.LastName, 1)) AS InsertUserInitials,
	p.GamingDate, 
	p.InsertTimeStampUTC ,
	GeneralPurpose.fn_UTCToLocal(1,p.InsertTimeStampUTC) AS Ora
FROM 
(
	--occhio qui!! funziona solo per gamigndate crescenti con PDFID!
	SELECT p.CustomerID,MAX(p.PDFID)  AS maxPDFID
	FROM Snoopy.tbl_CustomerDocPDF p
	INNER JOIN Snoopy.tbl_CustomerDocPDF pg ON pg.PDFID = p.PDFID
	GROUP BY p.CustomerID
) maxp 
INNER JOIN   Snoopy.vw_PersoneIdentificate c ON c.CustomerID = maxp.CustomerID
INNER JOIN Snoopy.tbl_CustomerDocPDF p ON maxp.CustomerID = p.CustomerID AND p.PDFID = maxp.maxPDFID
INNER JOIN FloorActivity.tbl_UserAccesses ua ON p.InsertUserAccessID = ua.UserAccessID
INNER JOIN CasinoLayout.Users u ON u.UserID = ua.UserID 
INNER JOIN Giotto.Snoopy.CustomerDocPDF pg ON pg.PDFID = p.PDFID









GO
