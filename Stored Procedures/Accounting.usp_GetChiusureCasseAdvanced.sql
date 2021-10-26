SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [Accounting].[usp_GetChiusureCasseAdvanced]
@gaming  DATETIME
AS
/*


declare
@gaming  datetime

set @gaming = '1.19.2019'

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
b.nome,
b.CHF,
b.Qty,
b.ExchangeRate
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
		SELECT [Accounting].[fn_Formulario_NAME_Advanced] (@gaming,DenoID) AS nome,
		--ValueTypeName,DenoName,
		SUM(ExchangeRate*Denomination*Qty) AS CHF ,
		SUM(Denomination*Qty) AS Qty ,
		ExchangeRate
		FROM @xb
		WHERE [Accounting].[fn_Formulario_NAME_Advanced] (@gaming,DenoID) IS NOT NULL
		GROUP BY [Accounting].[fn_Formulario_NAME_Advanced] (@gaming,DenoID),ExchangeRate
	) a

	--add diff cassa chf
	UNION ALL

	SELECT 
	'CASSE_' + Acronim + '_DIFFCASSA',
	SUM(ROUND([DiffCassa],2)) AS chf,
	SUM(ROUND([DiffCassa],4)) AS qty,
	1.0 AS ExchangeRate
	FROM Accounting.vw_AllStockDiffCassaEx d 
	WHERE d.GamingDate = @gaming
	GROUP BY Acronim
)b
ORDER BY b.nome
GO
GRANT EXECUTE ON  [Accounting].[usp_GetChiusureCasseAdvanced] TO [SolaLetturaNoDanni]
GO
