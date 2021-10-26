SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Marketing].[vw_LuckyConsegnate]
AS
SELECT 
     [RitiratoGamingDate]	AS GamingDate,
	 COUNT( [AssegnazionePremioID] )			AS TotLucky20,
	COUNT( [AssegnazionePremioID] )	* 4		AS TotPezzi,
	COUNT( [AssegnazionePremioID] )	* 4 * 5	AS TotValue
  FROM [Alamo].[Marketing].[tbl_AssegnazionePremi]
  WHERE [OffertaPremioID] = 102 AND CancelTimeUTC IS NULL
  GROUP BY [RitiratoGamingDate]
GO
