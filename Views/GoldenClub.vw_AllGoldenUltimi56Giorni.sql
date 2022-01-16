SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [GoldenClub].[vw_AllGoldenUltimi56Giorni]
WITH SCHEMABINDING
AS
	SELECT e.Customerid,
	MIN(e.gamingDate)	AS dal,
	MAX(e.gamingdate) AS Al,
	COUNT(DISTINCT e.Gamingdate) AS totEntrate
	FROM Reception.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	WHERE e.gamingdate >= GETDATE() - 56
	AND e.IsUscita = 0
	AND s.SiteTypeID = 2 --only records on sesam entrance
GROUP BY Customerid




GO
