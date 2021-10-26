SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
/*
SELECT *
  FROM [Alamo].Snoopy.vw_AllSesamControls
  WHERE GamingDate = '9.3.2019' AND SiteName = 'Sesam 3 Balconata'
  */
CREATE VIEW [Snoopy].[vw_SesamTentative3]
AS
SELECT
		'SiteName'	AS SiteName,
		1			AS SiteID,
		GETDATE()	AS GamingDate,
		GETDATE()	AS OrigTime2,
		'search'	AS search8,
		0			AS tentatives

/*
SELECT
		SiteName,
		SiteID,
		GamingDate,
		OrigTime2,
		search8,
		SUM(d.Tentatives) AS Tentatives
FROM
(
	SELECT 
		SiteName,
		SiteID,
		GamingDate,
		OrigTime,
		PrevTime,
		seconds,
		search8,
		prevsearch8,
		c.tentatives,
		CASE WHEN c.SameSearchString = 1 AND c.sametime = 1 THEN 1 ELSE 0 END AS IsAffinamento,
		CASE WHEN c.SameSearchString = 1 AND c.sametime = 1 THEN c.PrevTime ELSE c.OrigTime END AS OrigTime2
	FROM
	(

		SELECT 
		SiteName,
		SiteID,
		GamingDate,
		OrigTime,
		PrevTime,
		b.seconds,
		b.search8,
		b.prevsearch8,
		b.tentatives,

		CASE WHEN b.search8 = b.prevsearch8 THEN 1 ELSE 0 END AS SameSearchString,
		CASE WHEN b.seconds > -30 THEN 1 ELSE 0 END AS sametime
		FROM
		(
			SELECT 
			SiteName,
			SiteID,
			GamingDate,
			search8,
			prevsearch8,
			a.OrigTime,
			a.PrevTime,
			a.tentatives,
			DATEDIFF(SECOND,a.OrigTime,a.PrevTime) AS seconds
			FROM 
			(
				SELECT 
					SiteName,SiteID,OrigTime,GamingDate,search8,tentatives
					,LAG(search8,1,search8) OVER(PARTITION BY SiteID,GamingDate ORDER BY OrigTime ASC) AS PrevSearch8
					,LAG(OrigTime,1,OrigTime) OVER(PARTITION BY SiteID,GamingDate ORDER BY OrigTime ASC) AS PrevTime
				FROM Snoopy.vw_SesamTentative2
				--WHERE GamingDate = '9.3.2019' AND SiteName = 'Sesam 3 Balconata'
			) a
		) b
	) c
)d
--WHERE GamingDate = '9.3.2019' AND SiteName = 'Sesam 3 Balconata'
GROUP BY SiteName,
		SiteID,
		GamingDate,
		OrigTime2,
		search8

*/
GO
