SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [GoldenClub].[vw_AllEntrateGoldenClub]
WITH SCHEMABINDING
AS
SELECT 
e.CustomerID, 
e.entratatimestampLoc AS ora,
e.entratatimestampUTC,
e.CardID, 
c.LastName, 
c.FirstName,
e.GamingDate,
g.GoldenClubCardID,
g.CancelID ,
ca.CancelDateLoc AS CancelDate,
g.[MembershipTimeStampUTC] AS MemberFrom,
g.MemberTypeID,
doc.CitizenshipID,
CASE WHEN s.SiteTypeID = 2 THEN 1 ELSE 0	END AS IsSesamEntrance,
ce.[FDescription] AS CardEntryMode,
s.FName as SiteName,
sec.SectorName as Sector
FROM Reception.tbl_CustomerIngressi e
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = e.CustomerID
INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
LEFT OUTER JOIN GoldenClub.tbl_CardEntryMode ce ON ce.[PK_CardEntryModeID] = e.[FK_CardEntryModeID]
LEFT OUTER JOIN GoldenClub.tbl_Members g ON  g.CustomerID = e.CustomerID
LEFT OUTER JOIN Snoopy.tbl_IDDocuments doc ON  doc.IDDocumentID = g.IDDocumentID
LEFT OUTER JOIN FloorActivity.tbl_Cancellations ca ON ca.CancelID = g.CancelID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID 
WHERE e.IsUscita = 0



GO
