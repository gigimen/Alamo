SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  VIEW [Snoopy].[vw_AllCustomerDocPDF]
--WITH SCHEMABINDING
AS
SELECT  c.CustomerID, 
	c.Firstname,
	c.Lastname,
	c.IdentificationID, 
	c.IdentificationGamingDate, 
	p.PDFID, 
	p.OriginalFileName, 
	pg.PDFFileSize, 
	pg.PDFfile, 
	p.InsertUserAccessID,
        upper(left(u.FirstName,1)) + upper(left(u.LastName, 1)) As InsertUserInitials,
	p.GamingDate, 
	p.InsertTimeStampUTC ,
	GeneralPurpose.fn_UTCToLocal(1,p.InsertTimeStampUTC) as Ora
FROM    Snoopy.vw_PersoneIdentificate c
INNER JOIN Snoopy.tbl_CustomerDocPDF p ON c.CustomerID = p.CustomerID
INNER join FloorActivity.tbl_UserAccesses ua on p.InsertUserAccessID = ua.UserAccessID
INNER JOIN CasinoLayout.Users u ON u.UserID = ua.UserID 
LEFT OUTER JOIN Giotto.Snoopy.CustomerDocPDF pg on pg.PDFID = p.PDFID







GO
