SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE  VIEW [Accounting].[vw_DailyShortpays]
WITH SCHEMABINDING
AS
/*
select * from [Accounting].[vw_DailyShortpays]
where GamingDate >= '1.1.2019'
order by GamingDate

*/

SELECT	ISNULL(sp.GamingDate,jp.GamingDate) AS GamingDate,
		ISNULL(sp.CountShortpaysEUR		,0)		AS 	CountShortpaysEUR					,
		ISNULL(sp.CountShortpaysCHF		,0)		AS 	CountShortpaysCHF					,
		ISNULL(sp.ShortpaysEUR		,0)		AS 	ShortpaysEUR					,
		ISNULL(sp.ShortpaysCHF		,0)		AS 	ShortpaysCHF					,
		ISNULL(sp.ShortpaysTotCHF	,0)		AS 	ShortpaysTotCHF				,
		ISNULL(jp.Hits				,0)		AS 	SlotpotHits	,    
		ISNULL(jp.TotJackpot	    ,0)		AS 	TotSlotpot	    
FROM 
(
	SELECT t.[SourceGamingDate] AS GamingDate
		  ,count(CASE WHEN t.CurrencyID = 0 THEN [Quantity] * [Denomination] ELSE 0 END) AS CountShortpaysEUR
		  ,count(CASE WHEN t.CurrencyID = 4 THEN [Quantity] * [Denomination] ELSE 0 END) AS CountShortpaysCHF
		  ,SUM(CASE WHEN t.CurrencyID = 0 THEN [Quantity] * [Denomination] ELSE 0 END) AS ShortpaysEUR
		  ,SUM(CASE WHEN t.CurrencyID = 4 THEN [Quantity] * [Denomination] ELSE 0 END) AS ShortpaysCHF
		  ,SUM(CASE WHEN t.CurrencyID = 0 THEN [Quantity] * [Denomination] * r.IntRate ELSE [Quantity] * [Denomination] END) AS ShortpaysTotCHF

	  FROM [Accounting].[vw_AllTransactionDenominations] t
	  INNER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.SourceGamingDate AND r.CurrencyID = 0
	  WHERE t.OpTypeID = 6
	  AND t.DenoID IN (64,165) --shortpay in euro e sfr
	  GROUP BY t.[SourceGamingDate]
) sp
FULL OUTER JOIN
(
/*don't take it form the jackpot engine
SELECT count(*) as Hits,
	sum(hitValue) as Hitvalue,
	GamingDate
  FROM [dbo].[NewSlotpotInstances]
  group by GamingDate*/

--take it from Alamo
	SELECT [SourceGamingDate] AS GamingDate
			,COUNT(*) AS Hits
		  ,SUM([Quantity] * [Denomination]) AS TotJackpot
	  FROM [Accounting].[vw_AllTransactionDenominations]
	  WHERE OpTypeID = 6
	  AND DenoID = 100 --jackpots dello slotpot
	GROUP BY [SourceGamingDate]
) jp ON sp.GamingDate = jp.GamingDate
GO
