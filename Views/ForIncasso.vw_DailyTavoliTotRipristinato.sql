SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [ForIncasso].[vw_DailyTavoliTotRipristinato]
WITH SCHEMABINDING
AS

/*

select * FROM [ForIncasso].[vw_AllConsegnaRipristiniTavoli] where GamingDate = '6.27.2019'
select * FROM [ForIncasso].[vw_DailyTavoliTotRipristinato] where GamingDate = '6.27.2019'

*/

SELECT	'TAVOLI_TOT_RIP_' + a.Acronim AS 'ForIncassoTag',
		a.totRipristinato AS Amount,
		a.GamingDate
from
(
	SELECT COUNT([StockID]) AS tavoli
		  ,GamingDate
		  ,'EUR' AS Acronim
		  ,SUM([ConsegnaEUR]) AS totConsegnato
		  ,SUM([RipristinoEUR]) AS totRipristino
		  ,SUM([RipristinoEUR]) - SUM([ConsegnaEUR])  AS totRipristinato
	FROM [ForIncasso].[vw_AllConsegnaRipristiniTavoli]
	GROUP BY GamingDate--,StocktypeName

	UNION ALL

	SELECT COUNT([StockID]) AS tavoli
		  ,GamingDate
		  ,'CHF' AS Acronim
		  ,SUM([ConsegnaCHF]) AS totConsegnato
		  ,SUM([RipristinoCHF]) AS totRipristino
		  ,SUM([RipristinoCHF]) - SUM([ConsegnaCHF])  AS totRipristinato
	FROM [ForIncasso].[vw_AllConsegnaRipristiniTavoli]
	GROUP BY GamingDate--,StocktypeName
) a
--WHERE a.GamingDate = '6.27.2019'
GO
