SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [GoldenClub].[vw_AllGoldenUltimi180Giorni]
WITH SCHEMABINDING
AS
SELECT Customerid,
	MIN(gamingDate)	AS dal,
	MAX(gamingdate) AS Al,
	   COUNT(DISTINCT Gamingdate) AS totEntrate
FROM Reception.tbl_CustomerIngressi e
WHERE gamingdate >= GETDATE() - 180
AND IsUscita = 0
GROUP BY Customerid











GO
