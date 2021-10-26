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
CREATE VIEW [Snoopy].[vw_SesamTentative2]
AS
SELECT
		'SiteName'	AS SiteName,
		1			AS SiteID,
		GETDATE()	AS GamingDate,
		GETDATE()	as OrigTime,
		'search'	as search8,
		0			AS tentatives

/*
SELECT
		SiteName,
		SiteID,
		GamingDate,
		OrigTime,
		search8,
		COUNT(d.TimeStampUTC) AS tentatives
FROM
(
	SELECT 
		SiteName,
		SiteID,
		GamingDate,
		TimeStampUTC,
		PrevTimeUTC,
		seconds,
		searchString,
		search8,
		prevsearch,
		CASE WHEN c.SameSearchString = 1 AND c.sametime = 1 THEN 1 ELSE 0 END AS IsAffinamento,
		CASE WHEN c.SameSearchString = 1 AND c.sametime = 1 THEN c.PrevTimeUTC ELSE c.TimeStampUTC END AS OrigTime
	FROM
	(

		SELECT 
		SiteName,
		SiteID,
		GamingDate,
		TimeStampUTC,
		PrevTimeUTC,
		b.seconds,
		searchString,b.search8,
		prevsearch,
	

		CASE WHEN b.search8 = b.prevsearch8 THEN 1 ELSE 0 END AS SameSearchString,
		CASE WHEN b.seconds > -30 THEN 1 ELSE 0 END AS sametime
		FROM
		(
			SELECT 
			SiteName,
			SiteID,
			GamingDate,
			LEFT(searchString,8)	AS search8,
			LEFT(prevsearch,8)		AS prevsearch8,
			searchString,
			prevsearch,
			a.TimeStampUTC,
			a.PrevTimeUTC,
			DATEDIFF(SECOND,a.TimeStampUTC,a.PrevTimeUTC) AS seconds
			FROM 
			(
				SELECT 
					SiteName,SiteID,TimeStampUTC,GamingDate,searchString
					,LAG(searchString,1,searchString) OVER(PARTITION BY SiteID,GamingDate ORDER BY TimeStampUTC ASC) AS PrevSearch
					,LAG(TimeStampUTC,1,TimeStampUTC) OVER(PARTITION BY SiteID,GamingDate ORDER BY TimeStampUTC ASC) AS PrevTimeUTC
				FROM Snoopy.vw_AllSesamControls
				WHERE SiteTypeID = 2
				--WHERE GamingDate = '9.3.2019' AND SiteName = 'Sesam 3 Balconata'
			) a
		) b
	) c
)d
--WHERE GamingDate = '9.3.2019' AND SiteName = 'Sesam 3 Balconata'
GROUP BY SiteName,
		SiteID,
		GamingDate,
		OrigTime,
		search8
*/
GO
