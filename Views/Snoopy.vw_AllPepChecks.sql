SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Snoopy].[vw_AllPepChecks]
--WITH SCHEMABINDING
AS
SELECT  
	c.Lastname,
	c.firstname,
	p.PepCheckID, 
	pg.PDFFileSize, 
	pg.PDFfile, 
	p.PepCheckYear ,
	GeneralPurpose.fn_UTCToLocal(1,p.InsertTimeStampUTC) AS OraPepCheck,
	c.CustomerID, 
	c.IdentificationID, 
	ide.GamingDate AS IdentificationGamingDate,
	ide.IDCauseID,
	cau.FDescription AS Causa,
	UPPER(LEFT(u.FirstName,1)) + UPPER(LEFT(u.LastName, 1)) AS InsertUserInitials
FROM  Snoopy.tbl_PepChecks p
INNER JOIN FloorActivity.tbl_UserAccesses ua ON p.InsertUserAccessID = ua.UserAccessID
INNER JOIN CasinoLayout.Users u ON u.UserID = ua.UserID 
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = p.CustomerID
INNER JOIN Snoopy.tbl_Identifications ide ON ide.IdentificationID = c.IdentificationID
INNER JOIN Snoopy.tbl_IDCauses cau ON cau.IdCauseID = ide.IDCauseID
LEFT OUTER JOIN Giotto.Snoopy.PepChecks pg ON pg.PepCheckID = p.[PepCheckID]









GO
