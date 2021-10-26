SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [GoldenClub].[vw_TodayPastaDrinks]
WITH SCHEMABINDING
AS

SELECT s.SiteID,
		[GeneralPurpose].fn_GetGamingLocalDate2(
			GETUTCDATE(),
			DATEDIFF(hh,GETUTCDATE(),GETDATE()),
			7 --cassa centrale
			) AS GamingDate,
			ISNULL(a.PastaDrinks,0) AS PastaDrinks,
			isnull(a.Accompagnatori,0) AS Accompagnatori
FROM CasinoLayout.Sites s
	LEFT OUTER JOIN 
	(
		SELECT SiteID,
		ISNULL(SUM([Accompagnatori]),0) AS [Accompagnatori]
		,COUNT(*) AS PastaDrinks
		FROM GoldenClub.tbl_PartecipazioneCena
		WHERE [TipoCenaID] = 3
		AND GamingDate = [GeneralPurpose].fn_GetGamingLocalDate2(
			GETUTCDATE(),
			DATEDIFF(hh,GETUTCDATE(),GETDATE()),
			7 --cassa centrale
			)
		GROUP BY SiteID	
	) a ON a.SiteID = s.SiteID
GO
