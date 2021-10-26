SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [GoldenClub].[vw_AllPartecipazioneCene]
WITH SCHEMABINDING
AS
SELECT c.CustomerID, 
c.LastName, 
c.FirstName, 
COUNT(*) AS TotCene, 
GeneralPurpose.fn_UTCToLocal(1, MIN(g.InsertTimeStampUTC)) AS PrimaPartecipazione, 
GeneralPurpose.fn_UTCToLocal(1, MAX(g.InsertTimeStampUTC)) AS UltimaPartecipazione
FROM GoldenClub.tbl_PartecipazioneCena AS g 
INNER JOIN GoldenClub.tbl_Members AS gc ON gc.CustomerID = g.CustomerID 
INNER JOIN Snoopy.tbl_Customers AS c ON c.CustomerID = g.CustomerID
GROUP BY c.CustomerID, c.LastName, c.FirstName





GO
