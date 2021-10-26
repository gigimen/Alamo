SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [GoldenClub].[vw_AllGoldenGiorniPreferiti]
WITH SCHEMABINDING
AS
SELECT a.customerid,max(a.giorniPref) as giorniPref,max(a.maxentrate) as maxentrate,min(b.wday) as wday
FROM
(
	SELECT d.customerid,COUNT(*) AS giorniPref,MAX(d.totEntrate) AS maxentrate
	FROM
	(
		SELECT Customerid,
			  COUNT(distinct GamingDate) AS totentrate
			  ,DATEPART(weekday,[GamingDate]) AS wday
			  ,DATENAME(weekday,gamingdate) AS dname
		  FROM Snoopy.tbl_CustomerIngressi e
		  INNER JOIN CasinoLayout.Sites s ON e.SiteID = s.SiteID
		  WHERE gamingdate >= GETDATE() - 180
		  AND IsUscita = 0
		  AND s.SiteTypeID = 2
		  GROUP BY Customerid
				,DATEPART(weekday,[GamingDate])
			  ,DATENAME(weekday,gamingdate)
	) d
	GROUP BY d.customerid
	HAVING COUNT(*) <= 2 
)a
INNER JOIN 
(
	SELECT Customerid,
		  COUNT(distinct GamingDate) AS totentrate
		  ,DATEPART(weekday,[GamingDate]) AS wday
		  ,DATENAME(weekday,gamingdate) AS dname
	  FROM Snoopy.tbl_CustomerIngressi e
		  INNER JOIN CasinoLayout.Sites s ON e.SiteID = s.SiteID
		  WHERE gamingdate >= GETDATE() - 180
		  AND IsUscita = 0
		  AND s.SiteTypeID = 2
	  GROUP BY Customerid
			,DATEPART(weekday,[GamingDate])
		  ,DATENAME(weekday,gamingdate)
)b ON a.CustomerId = b.CustomerID AND  a.maxentrate = b.totentrate
group by  a.customerid













GO
