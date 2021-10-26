SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Snoopy].[vw_CurrentVisitors]
AS


SELECT (SELECT MAX(gamingdate) FROM Accounting.tbl_LifeCycles)		AS GamingDate,
		ISNULL(c.controls,0) + ISNULL(v.visita,0)				AS visite,
		CASE
			WHEN c.Ultima IS NULL THEN v.ultima
			WHEN v.ultima IS NULL THEN c.ultima 
			WHEN c.ultima > v.ultima	THEN c.ultima
			ELSE
			v.ultima	END										AS ultimaVisita
FROM
(
	SELECT 
			COUNT(*) AS controls,
			MAX(c.TimeStampLoc)			AS ultima
	FROM Snoopy.tbl_VetoControls c
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	AND c.GamingDate = (SELECT MAX(gamingdate) FROM Accounting.tbl_LifeCycles)

) c
CROSS JOIN 
(
	--add to entrance all card swapped (ckey query not used)
	SELECT	COUNT(DISTINCT Customerid) AS visita,
			MAX(e.entratatimestampLoc) AS ultima
	FROM Snoopy.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	WHERE CardID IS NOT NULL  AND  s.SiteTypeID = 2  --count all research done only at sesam
	AND e.GamingDate = (SELECT MAX(gamingdate) FROM Accounting.tbl_LifeCycles)

) v 



GO
