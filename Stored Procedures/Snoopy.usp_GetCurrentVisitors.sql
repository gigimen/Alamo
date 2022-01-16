SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [Snoopy].[usp_GetCurrentVisitors]
AS

DECLARE @gaming DATETIME
SET @gaming = generalpurpose.fn_GetGamingLocalDate2(
		GETUTCDATE(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GETUTCDATE(),GETDATE()),
		7 --Cassa Centrale StockTypeID 
		)
SELECT @gaming										AS GamingDate,
		ISNULL(c.controls,0) + ISNULL(v.visita,0)	AS visite
FROM
(
	SELECT COUNT(*) AS controls
	FROM Reception.tbl_VetoControls c
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteID 
	INNER JOIN CasinoLayout.SiteTypes st ON st.SiteTypeID = s.SiteTypeID
	WHERE st.SiteTypeID = 2  --count only sesam entrances
	AND c.GamingDate = @gaming

) c
CROSS JOIN 
(
	--add to entrance all card swapped (ckey query not used)
	SELECT COUNT(DISTINCT Customerid) AS visita
	FROM Reception.tbl_CustomerIngressi e
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = e.SiteID
	WHERE CardID IS NOT NULL  AND  s.SiteTypeID = 2  --count all research done only at sesam
	AND e.GamingDate = @gaming

) v 


GO
