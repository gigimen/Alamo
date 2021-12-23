SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [ForIncasso].[usp_GetChiusureCasse]
@gaming  DATETIME
AS
/*


declare
@gaming  datetime

set @gaming = '7.14.2019'

execute [ForIncasso].[usp_GetChiusureCasse] @gaming
--*/
declare

@EuroRate float ,
@totStock float 

declare @xb table 
(
OpName varchar(256),
DenoID int,
ValueTypeID int,
ValueTypeName varchar(128),
DenoName varchar(64),
Denomination float,
IsFisical	BIT,
ExchangeRate float,
Qty			int
)

insert @xb
EXEC	[Accounting].[usp_GetXBalanceDenominations]
		@gaming,
		1,--@trolleys = 1,
		1,--@Chiusura = 1,
		@EuroRate OUTPUT,
		@totStock OUTPUT

--select * from @xb order by ValueTypeID,DenoID
SELECT 
c.ForIncassoTag,
c.Amount
FROM
(
	SELECT 
	b.nome	AS ForIncassoTag,
	b.CHF	AS Amount/*,
	b.Qty,
	b.ExchangeRate*/
	FROM
	(
		SELECT a.nome,
			CASE WHEN nome IN(
			'CASSE_EUR_DENARO_TROVATO','CASSE_CHF_DENARO_TROVATO',
			'CASSE_UTILE_VENDITAEURO',
			'CASSE_EUR_RETT_DIFF','CASSE_CHF_RETT_DIFF',
			'COMMISSIONI_EUR_CC_ADUNO',
			'COMMISSIONI_EUR_ASSEGNI'
			)
				THEN -a.CHF
				ELSE
				a.CHF
			END AS CHF,
			a.Qty,
			a.ExchangeRate
			FROM
			(
				SELECT [ForIncasso].[fn_FormIncassoTag] (@gaming,DenoID) AS nome,
				--ValueTypeName,DenoName,
				SUM(ExchangeRate*Denomination*Qty) AS CHF ,
				SUM(Denomination*Qty) AS Qty ,
				ExchangeRate
				FROM @xb
				WHERE [ForIncasso].[fn_FormIncassoTag] (@gaming,DenoID) IS NOT NULL
				GROUP BY [ForIncasso].[fn_FormIncassoTag] (@gaming,DenoID),ExchangeRate
			) a
	)b
	UNION ALL
	(
/*  vecchio modo 
	SELECT 'CASSE_' + [CurrencyAcronim] + '_GETTONI' AS ForIncassoTag,
			  SUM([Chiusura]) - SUM(Apertura) AS Amount
		FROM [ForIncasso].[vw_DailyGettoniCasse]
		WHERE GamingDate = @gaming
		GROUP BY [CurrencyAcronim]
		*/
		SELECT 'CASSE_' + CASE WHEN ValueTypeID = 59 THEN 'POK' ELSE [Acronim] END + '_GETTONI' AS ForIncassoTag,
			  SUM([Conteggio]) - SUM(Apertura) - SUM(verspoker) AS Amount 
		FROM [ForIncasso].[fn_GetChiusureCashCasse]  (@gaming)
		WHERE ValueTypeID IN (1,36,42,59)
		GROUP BY CASE WHEN ValueTypeID = 59 THEN 'POK' ELSE [Acronim] END


	)
)c
ORDER BY c.ForIncassoTag
GO
