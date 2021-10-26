SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









/*
A partire dal 20.1.2017 separiamo le visite dalle entrate
visite:		piu' visite dello stesso cliente valgono una entrata sola per la giornata
entrate:	piu' visite dello stesso cliente valgono ognuna 1 entrata nel computo della giornata
*/
CREATE VIEW [GoldenClub].[vw_CKEntrancesByGamingDate]
AS
/*

SELECT * FROM GoldenClub.vw_CKEntrancesByGamingDate
WHERE GamingDate >= '10.1.2019'
order by GamingDate

*/

SELECT  oi.GamingDate,
		oi.OldIngressi,
		oa.OldIngressiAlamo,
		oa.OldVisiteAlamo,
		c1.SesamControls,
		e.IngressiAlamo,
		e.VisiteAlamo,
		e.PickedFromList,
		g.IngressiMembri,
		g.VisiteMembri,
		c1.[SesamControls] + e.[VisiteAlamo]	AS VisiteTotali,
		oi.OldIngressi + oa.OldVisiteAlamo		AS OldVisiteTotali,
		c1.[SesamControls] + e.[IngressiAlamo]	AS EntrateTotali,
		oi.OldIngressi + oa.OldIngressiAlamo	AS OldEntrateTotali
FROM
(

	SELECT GamingDate,COUNT(*) AS OldIngressi
	FROM Snoopy.tbl_VetoControls c
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	GROUP BY c.GamingDate

) oi 
LEFT OUTER JOIN
(
	SELECT e.GamingDate,
			COUNT(*) AS OldIngressiAlamo,
			COUNT(DISTINCT CustomerID) AS OldVisiteAlamo
	FROM Snoopy.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	WHERE CardID IS NOT NULL  
	AND  s.SiteTypeID = 2  --count all research done only at sesam	
	GROUP BY e.GamingDate
) oa ON oa.GamingDate = oi.GamingDate
LEFT OUTER JOIN
(
	SELECT e.GamingDate,
			COUNT(*) AS IngressiAlamo,
			COUNT(DISTINCT CustomerID) AS VisiteAlamo,
			SUM( CASE WHEN e.[FK_CardEntryModeID] = 4 THEN 1 ELSE 0 END) AS PickedFromList
	FROM Snoopy.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	WHERE s.SiteTypeID = 2  --count all research done only at sesam
	GROUP BY e.GamingDate
) e ON e.GamingDate = oi.GamingDate
LEFT OUTER JOIN
(
	SELECT 
	GamingDate,
	COUNT(*) AS IngressiMembri, 
	COUNT(DISTINCT CustomerID) AS VisiteMembri
	FROM GoldenClub.vw_AllEntrateGoldenClub
	WHERE (CancelDate IS NULL OR CancelDate > GamingDate)
	AND (MemberFrom IS NOT NULL AND MemberFrom <= GamingDate) 
	AND IsSesamEntrance = 1
	GROUP BY GamingDate
) g ON g.GamingDate = oi.GamingDate
LEFT OUTER JOIN
(
-- changed the 15-10-2019 to the new table Snoopy.tbl_Ingressi
/*	SELECT	c.GamingDate,
			COUNT(*) AS SesamControls
	FROM Snoopy.tbl_VetoControls c
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	GROUP BY c.GamingDate
*/
	SELECT	i.GamingDate,
			COUNT(*) AS SesamControls
	FROM Snoopy.tbl_FasceEtaRegistrations i
	INNER JOIN [Snoopy].[tbl_VetoControls] c ON c.PK_ControllID = i.[FK_ControlID]
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	GROUP BY i.GamingDate


) c1 ON c1.GamingDate = oi.GamingDate
GO
