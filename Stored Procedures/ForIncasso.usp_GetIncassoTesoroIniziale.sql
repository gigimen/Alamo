SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [ForIncasso].[usp_GetIncassoTesoroIniziale] 
@gaming			datetime
AS

/*

declare @gaming datetime

set @gaming = '10.14.2019'

*/

if @gaming is null or @gaming = null
BEGIN
	--we always have to specify the gaming date 
	--otherwise we have troubles getting the previous close gaming date
	RAISERROR('Specify a valid Gaming Date',16,1)
	RETURN (1)
END


/*


declare @gaming			datetime

set @gaming = '12.21.2020'
--execute [ForIncasso].[usp_GetIncassoTesoroIniziale]   @gaming		


--*/



declare @giornoprima datetime

set @giornoprima =  dateadd(day,-1,@gaming)
declare @AperturaTesoro as table (
ValueTypeName varchar(32) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Total	int,
maxtimeLoc	datetime)

insert into @AperturaTesoro execute [ForIncasso].[usp_GetAperturaTesoroEx] @gaming


--select * from @AperturaTesoro

/*


declare @gaming			datetime

set @gaming = '10.25.2017'
--execute [Accounting].[usp_GetIncassoStatoIniziale] @gaming		


--*/
/*
SELECT 
---guarda il conteggio dell'incasso registrato il giorno prima
	case
		when [DenoID] = 48 then 'INCASSO_TESORO_APERTURA_CHF'
		else 'INCASSO_TESORO_APERTURA_VALUTE' 
	end as Nome,
	case
		when [DenoID] = 48 then 'CHF'
		else 'Valute estere' 
	end as Cosa,
	case
		when [DenoID] = 48 then  [DenoID]
		else 138 end as DenoID
	,sum(Quantity) as Quantity
	--YUL:   come faceva yiulia nel formulario arrotondiamo in basso ai 5 centesimi di franco e poi sommiamo
	--,sum([GeneralPurpose].[fn_Floor]([ValueSfr],0.05)) as ValueSfr
	,sum([ValueSfr]) as ValueSfr
	, [ConteggioTimeUTC]
	, [ConteggioTimeLoc]
FROM [Accounting].[vw_AllConteggiDenominations]
WHERE [GamingDate] = @giornoprima and SnapshotTypeID = 6 --solo conteggi uscita
and StockID = 47 --incasso
group by 
	case
		when [DenoID] = 48 then 'INCASSO_TESORO_APERTURA_CHF'
		else 'INCASSO_TESORO_APERTURA_VALUTE' 
	end,
	case
		when [DenoID] = 48 then 'CHF'
		else 'Valute estere' 
	end,
	case
		when [DenoID] = 48 then  [DenoID]
		else 138 end 
		, [ConteggioTimeUTC]
		, [ConteggioTimeLoc]
		*/
/* il vecchio modo dai conteggi

SELECT 
---guarda il conteggio dell'incasso registrato il giorno prima
	'INCASSO_TESORO_APERTURA_'+ [CurrencyAcronim] as ForIncassoTag,
	SUM(Quantity*Denomination) as Amount --interested only in valuta
FROM [Accounting].[vw_AllConteggiDenominations]
WHERE [GamingDate] = @giornoprima and SnapshotTypeID = 6 --solo conteggi uscita
and StockID = 47 --incasso
group by 	[CurrencyAcronim]
*/
SELECT 'INCASSO_TESORO_APERTURA_' + CurrencyAcronim AS ForIncassoTag,
SUM(Quantity * Denomination) as Amount
FROM Accounting.vw_AllSnapshotDenominations t
inner join [Accounting].[fn_GetLastLifeCycleByStock] (@giornoprima,47) l on t.LifeCycleID = l.LifeCycleID
where t.SnapshotTypeID = 3 --solo chiusure
and t.StockID = 47 --incasso
GROUP BY CurrencyAcronim

union all

--aggiungiamo gli stock della gastro e degli ecash
/* vecchio modo preso dallo snashot di conteggio uscita



declare @giornoprima			datetime
set @giornoprima = '4.25.2020'

SELECT [DenoName] as ForIncassoTag
		,[Quantity] * [Denomination] as Amount
FROM [Accounting].[vw_AllSnapshotDenominations]
where StockID = 47 and SnapshotTypeID = 6 and GamingDate = @giornoprima
*/
/*nuovo modo preso dal conteggio uscita





declare @giornoprima			datetime
set @giornoprima = '2.9.2022'
--*/

SELECT case
when stockid = 75	then 'KIOSK_STOCK_APERTURA_CHF1'
when stockid = 79	then 'KIOSK_STOCK_APERTURA_CHF2'
when stockid = 85	then 'GASTRO_TESORO_APERTURA'
when stockid = 80	then 'KIOSK_STOCK_APERTURA_EUR1'
when stockid = 81	then 'KIOSK_STOCK_APERTURA_EUR2'
END AS ForIncassoTag
,Totale as Amount
 from [Accounting].[vw_ChiusuraFormIncasso]
where GamingDate = (

	select max(GamingDate) from [Accounting].[vw_AllConteggiDenominations]
	where SnapshotTypeID = 6 and GamingDate <= @giornoprima
	AND StockID IN(
	75,
	79,
	85,
	80,
	81
	)
)
AND StockID IN(
75,
79,
85,
80,
81
)
/*LM:11.20.2022 vecchio modo
SELECT case
when stockid = 75	then 'KIOSK_STOCK_APERTURA_CHF1'
when stockid = 79	then 'KIOSK_STOCK_APERTURA_CHF2'
when stockid = 85	then 'GASTRO_TESORO_APERTURA'
when stockid = 80	then 'KIOSK_STOCK_APERTURA_EUR1'
when stockid = 81	then 'KIOSK_STOCK_APERTURA_EUR2'
END AS ForIncassoTag
		,[Quantity] * [Denomination] as Amount
FROM [Accounting].[vw_AllConteggiDenominations]
where SnapshotTypeID = 6 and GamingDate = (

	select max(GamingDate) from [Accounting].[vw_AllConteggiDenominations]
	where SnapshotTypeID = 6 and GamingDate <= @giornoprima
	AND StockID IN(
	75,
	79,
	85,
	80,
	81
	)
)
AND StockID IN(
75,
79,
85,
80,
81
)
*/

union all
--aggiungiamo apertura tesoro
/*


declare @gaming			datetime
declare @AperturaTesoro as table (ValueTypeID	int,ValueTypeName varchar(32), valueSfr	float, Quantity	int,maxtimeLoc	datetime,maxtimeUTC datetime)

set @gaming = '10.15.2019'


insert into @AperturaTesoro execute [Accounting].[usp_GetAperturaTesoro] @gaming

select * from @AperturaTesoro
--*/

select 'X_BAL_AP_IERI_' + UPPER(ValueTypeName)  AS ForIncassoTag,
	Total AS Amount
from @AperturaTesoro
GO
