SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Marketing].[vw_Natale2018_Consegna]
AS
SELECT 'Consegna: Vignette (' + CAST(v.Vignette AS VARCHAR(16)) + '/' + CAST(v2.Vignette AS VARCHAR(16)) + ')' AS Consegna
FROM
(
	SELECT COUNT(DISTINCT v.AssegnazionePremioID) AS Vignette
	FROM [Marketing].[tbl_AssegnazionePremi] v
	WHERE (v.OffertaPremioID = 100 AND v.RitiratoTimeStampUTC IS NOT NULL) 
)v
CROSS JOIN
(
	SELECT COUNT(DISTINCT v.AssegnazionePremioID) AS Vignette
	FROM [Marketing].[tbl_AssegnazionePremi] v
	WHERE (v.OffertaPremioID = 100 AND v.CancelTimeUTC IS NULL) 
)v2
GO
