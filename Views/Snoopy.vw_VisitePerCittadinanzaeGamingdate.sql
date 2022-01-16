SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Snoopy].[vw_VisitePerCittadinanzaeGamingdate]
AS
SELECT	v.GamingDate,
		p.CitizenshipID,
		SUM(v.Visite) AS Visite
FROM 
(
		SELECT 
			GamingDate
			,[CustomerID]
			,COUNT(DISTINCT CustomerID) AS Visite
		FROM Reception.tbl_CustomerIngressi
		GROUP BY CustomerID,GamingDate
) v
INNER JOIN
(	
		SELECT 
			c.CustomerID,
			doc.CitizenshipID	     
		FROM Snoopy.tbl_IDDocuments doc
		INNER JOIN 
		(
			SELECT CustomerID,MAX(IDDocumentID) AS MaxDocID FROM Snoopy.tbl_IDDocuments
			GROUP BY CustomerID
		) c ON c.CustomerID = doc.CustomerID AND c.MaxDocID = doc.IDDocumentID
		WHERE c.CustomerID > 1
	
) p ON p.CustomerID = v.CustomerID 
--WHERE v.GamingDate = '2.1.2020'
--ORDER BY p.CustomerID,p.DomicilioID


GROUP BY v.GamingDate,p.CitizenshipID

GO
