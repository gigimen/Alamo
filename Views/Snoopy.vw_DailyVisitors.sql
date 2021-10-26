SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Snoopy].[vw_DailyVisitors]
WITH SCHEMABINDING
AS

SELECT	ISNULL(c.GamingDate,v.gamingdate ) AS gamingdate,
		c.controls,
		v.visita,
		ISNULL(c.controls,0) + ISNULL(v.visita,0) AS visite,
		ISNULL(c.controls,0) + ISNULL(v.IngressiAlamo,0) AS entrate,
		CASE
			WHEN c.Ultima IS NULL THEN v.ultima
			WHEN v.ultima IS NULL THEN c.ultima 
			WHEN c.ultima > v.ultima	THEN c.ultima
			ELSE
			v.ultima	END										AS ultimaVisita
FROM
(
	SELECT 	COUNT(*)					AS controls,
			MAX(c.TimeStampLoc)			AS ultima,
			i.GamingDate
	FROM Snoopy.tbl_FasceEtaRegistrations i
	INNER JOIN [Snoopy].[tbl_VetoControls] c ON c.PK_ControllID = i.[FK_ControlID]
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	GROUP BY i.gamingdate


) c
FULL OUTER JOIN 
(

	SELECT e.GamingDate,
			COUNT(*) AS IngressiAlamo,
			COUNT(DISTINCT Customerid) AS Visita,
			MAX(e.entratatimestampLoc) as ultima
	FROM Snoopy.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	WHERE s.SiteTypeID = 2  --count all research done only at sesam
	GROUP BY e.GamingDate

) v ON v.Gamingdate = c.gamingdate


--where c.GamingDate = '3.9.2020'

GO
