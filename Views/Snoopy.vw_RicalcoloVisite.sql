SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Snoopy].[vw_RicalcoloVisite]
AS
SELECT 
ck.GamingDate,
ck.Visite , 
a.controls + b.strisciate AS visite2,
a.controls,
c.OldControls,
c.newControls,
c.OldControls + b.strisciate AS oldvisite ,
c. newControls + b.strisciate AS newvisite 
FROM Snoopy.tbl_EntrateSummary ck 
INNER JOIN 
(
	select gamingdate,COUNT(*) AS controls
	from Snoopy.vw_AllSesamControls c
	inner join CasinoLayout.Sites s on s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	where st.SiteTypeID = 2  --count only sesam entrances
	GROUP BY c.gamingdate
) a ON a.GamingDate = ck.GamingDate
INNER JOIN 
(
--add to entrance all card swapped (ckey query not used)
	select gamingdate,COUNT(distinct Customerid) As strisciate
	FROM Snoopy.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	where CardID is not null  and  s.SiteTypeID = 2  --count all research done only at sesam
	GROUP BY e.GamingDate
) b ON a.GamingDate = b.gamingdate
INNER JOIN 
(
	SELECT GamingDate,COUNT(*) AS newControls,SUM([Tentatives]) AS OldControls
	FROM [Snoopy].[vw_SesamTentative3]
	GROUP BY GamingDate
) c ON c.GamingDate = ck.GamingDate
--WHERE a.GamingDate >= '1.1.2013'


GO
