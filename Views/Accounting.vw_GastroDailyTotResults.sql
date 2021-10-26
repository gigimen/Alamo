SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_GastroDailyTotResults]
AS
SELECT 
	GamingDate,
	SUM(IncassoTCPOS)		AS TotIncasso,
	SUM(Mance)				AS TotMance
FROM [Accounting].[vw_GastroDailyCageResults]
GROUP BY GamingDate
GO
