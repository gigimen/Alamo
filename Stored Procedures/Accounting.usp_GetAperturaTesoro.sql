SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [Accounting].[usp_GetAperturaTesoro] 
@gaming			datetime
AS


if @gaming is null or @gaming = null
BEGIN
	--we always have to specify the gaming date 
	--otherwise we have troubles getting the previous close gaming date
	RAISERROR('Specify a valid Gaming Date',16,1)
	RETURN (1)
END




/*

DECLARE @gaming DATETIME

SET @gaming = '1.21.2019'

--*/

DECLARE @ieri DATETIME
set @ieri = @gaming - 1

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#StockStatus%'
	)
begin
	print 'dropping #StockStatus'
	DROP TABLE #StockStatus
END


IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChiusureStocks%'
	)
begin
	print 'dropping #ChiusureStocks'
	DROP TABLE #ChiusureStocks
END

declare @Apertura as table (ValueTypeID int,ValueTypeName varchar(32),Quantity int,ValueSfr float,timeLoc datetime,timeUTC datetime)

--go with stock status
select
	s.Tag,
	s.FName,
	s.StockTypeID,
	s.StockID,
	@gaming as GamingDate,
	lf.GamingDate as LastGamingDate,
	lc.LifeCycleID,
	lc.CloseSnapshotID,
	lf.StockCompositionID,
	r.ChiusuraSnapshotID,
	r.CONTransactionID,
	r.RipSourceLifeCycleID,
	r.RipGamingDate,
	r.RIPTransactionID,
	r.ChiusuraTime as OraChiusura,
	r.[ChiusuraTimeUTC]
--let start from the active Stocks
INTO #StockStatus
FROM CasinoLayout.Stocks s 
INNER JOIN [Accounting].[fn_GetLastLifeCycleByStockType](@ieri,null) lc on lc.StockID = s.StockID 
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = lc.LifeCycleID
inner join [Accounting].[vw_AllChiusuraConsegnaRipristino] r on r.LifeCycleID = lc.LifeCycleID
WHERE s.StockTypeID in(2,4,6,7) --trolleys,cc,mainstock,riserva
AND @gaming >= s.FromGamingDate 
AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS null) 

--SELECT * FROM #StockStatus



--go with stock status
select
	s.Tag,
	s.FName,
	s.StockTypeID,
	s.StockID,
	s.GamingDate,
	s.LastGamingDate,
	s.LifeCycleID,
	s.OraChiusura,
	s.ChiusuraTimeUTC,
	s.RIPTransactionID,
	s.StockCompositionID,
	den.DenoID,
	den.FName as DenoName,
	den.Denomination,
	den.ValueTypeID,
	vt.FName as ValueTypeName,
	isnull((ch.Quantity),0)								as Chiusura,
	isnull((rip.Quantity),0)							as Ripristino,
	isnull(rip.ExchangeRate,1)							as RipExchangeRate
INTO #ChiusureStocks
FROM #StockStatus s 
inner join CasinoLayout.StockCompositions sc ON sc.StockCompositionID = s.StockCompositionID 
inner JOIN CasinoLayout.StockComposition_Denominations sd ON sc.StockCompositionID = sd.StockCompositionID 
inner JOIN CasinoLayout.tbl_Denominations den ON sd.DenoID = den.DenoID 
inner join CasinoLayout.tbl_ValueTypes vt on vt.ValueTypeID = den.ValueTypeID
--inner join CasinoLayout.vw_allStockCompositions den on den.StockCompositionID = s.StockCompositionID
left outer	join [Accounting].[vw_AllSnapshotDenominations] ch on ch.LifeCycleSnapshotID = s.ChiusuraSnapshotID and den.DenoID = ch.DenoID
left outer	join [Accounting].[vw_AllTransactionDenominations] rip on rip.TransactionID = s.RIPTransactionID and den.DenoID = rip.DenoID
where den.ValueTypeID in (1,2,3,7,36) 
--and den.DenoID in(1,128)

--select * from #ChiusureStocks order by StockID,DenoID

insert into @Apertura
select 
	case when s.ValueTypeID in(1,36) then 1
	else s.ValueTypeID end as ValueTypeID,
	case when s.ValueTypeID in(1,36) then 'GETTONI' when s.ValueTypeID = 3 then 'MONETE'
	else UPPER(ValueTypeName) end as ValueTypeName,
--	DenoID,
--	DenoName,
	sum((Chiusura + Ripristino)) as Quantity,
	sum((Chiusura + Ripristino)*Denomination) as ValueSfr,
	max(s.OraChiusura) as ChiusuraTime,
	max(s.ChiusuraTimeUTC) as ChiusuraTimeUTC
from #ChiusureStocks s
group by 
case when s.ValueTypeID in(1,36) then 1
	else s.ValueTypeID end ,
case when s.ValueTypeID in(1,36) then 'GETTONI' when s.ValueTypeID = 3 then 'MONETE'
	else UPPER(ValueTypeName) end
	--,DenoID,
	--DenoName

	--order by ValueTypeID,DenoID

/*
group by cont.Tag,
		cont.StockID,
		s.ReopenGamingDate,
		s.GamingDate*/

		--order by cont.StockID

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#StockStatus%'
	)
begin
	print 'dropping #StockStatus'
	DROP TABLE #StockStatus
END

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChiusureStocks%'
	)
begin
	print 'dropping #ChiusureStocks'
	DROP TABLE #ChiusureStocks
END

insert into @Apertura
SELECT	22,
		'DEPOSITI_CHF'
		,ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination),0)		as Quantity
		,ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination * DepOnValues.ExchangeRate),0)			As ValueSfr
		,max(DepOn.[CustomerTransactionTime]) AS DepOnTimeLoc
		,max(DepOn.[CustomerTransactionTime]) as DepOnTimeUTC
--from Snoopy.vw_allDepositi 
FROM  Snoopy.tbl_Depositi dep
	INNER JOIN  Snoopy.tbl_CustomerTransactions DepOn ON dep.DepoCustTransID = DepOn.CustomerTransactionID AND DepOn.CustTrCancelID IS NULL
	INNER JOIN Accounting.tbl_LifeCycles DepOnLF ON DepOnLF.LifeCycleID = DepOn.SourceLifeCycleID 
	INNER JOIN Snoopy.tbl_CustomerTransactionValues DepOnValues ON DepOnValues.CustomerTransactionID = DepOn.CustomerTransactionID 
	INNER JOIN CasinoLayout.tbl_Denominations DepOnDenos ON DepOnValues.DenoID = DepOnDenos.DenoID
	INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = DepOnDenos.ValueTypeID
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactions DepOff	ON dep.PrelevCustTransID = DepOff.CustomerTransactionID AND DepOff.CustTrCancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_LifeCycles DepOffLF ON DepOffLF.LifeCycleID = DepOff.SourceLifeCycleID 
where DepOn.CustTrCancelID IS NULL and DepOnLF.GamingDate <= @ieri
and (
		dep.PrelevCustTransID is null --still have to be prelevata 
		or
		DepOffLF.GamingDate > @ieri --prelevate today
	)
AND vt.CurrencyID = 4

insert into @Apertura
SELECT	23,
		'DEPOSITI_EUR'
		,ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination),0)		as Quantity
		,ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination * DepOnValues.ExchangeRate),0)			As ValueSfr
		,max(DepOn.[CustomerTransactionTime]) AS DepOnTimeLoc
		,max(DepOn.[CustomerTransactionTime]) as DepOnTimeUTC
--from Snoopy.vw_allDepositi 
FROM  Snoopy.tbl_Depositi dep
	INNER JOIN  Snoopy.tbl_CustomerTransactions DepOn ON dep.DepoCustTransID = DepOn.CustomerTransactionID AND DepOn.CustTrCancelID IS NULL
	INNER JOIN Accounting.tbl_LifeCycles DepOnLF ON DepOnLF.LifeCycleID = DepOn.SourceLifeCycleID 
	INNER JOIN Snoopy.tbl_CustomerTransactionValues DepOnValues ON DepOnValues.CustomerTransactionID = DepOn.CustomerTransactionID 
	INNER JOIN CasinoLayout.tbl_Denominations DepOnDenos ON DepOnValues.DenoID = DepOnDenos.DenoID
	INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = DepOnDenos.ValueTypeID
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactions DepOff	ON dep.PrelevCustTransID = DepOff.CustomerTransactionID AND DepOff.CustTrCancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_LifeCycles DepOffLF ON DepOffLF.LifeCycleID = DepOff.SourceLifeCycleID 
where DepOn.CustTrCancelID IS NULL and DepOnLF.GamingDate <= @ieri
and (
		dep.PrelevCustTransID is null --still have to be prelevata 
		or
		DepOffLF.GamingDate > @ieri --prelevate today
	)
AND vt.CurrencyID = 0

--select * from @Apertura

select 
case 
	when ValueTypeID = 2		THEN 1 
	when ValueTypeID = 1		then 3 
	when ValueTypeID = 22		then 4 
	when ValueTypeID = 3		then 2 
end												as ValueTypeID,
case 
WHEN ValueTypeID in(2) then 'BANCONOTE_CHF' 
WHEN ValueTypeID in(3) then 'MONETE_CHF' 
WHEN ValueTypeID in(1) then 'GETTONI_CHF' 
WHEN ValueTypeID in(7) then 'BANCONOTE_EUR' 
ELSE UPPER(ValueTypeName) end					AS ValueTypeName,
sum(ValueSfr)									as valueSfr,
sum(Quantity)									as Quantity,
max(timeLoc)									as maxtimeLoc,
max(timeUTC)									as maxtimeUTC
from @Apertura
group by 
case 
	when ValueTypeID = 2 then 1 
	when ValueTypeID = 1 then 3 
	when ValueTypeID = 22 then 4 
	when ValueTypeID = 3 then 2 
end ,
case 
WHEN ValueTypeID in(2) then 'BANCONOTE_CHF' 
WHEN ValueTypeID in(3) then 'MONETE_CHF' 
WHEN ValueTypeID in(1) then 'GETTONI_CHF' 
WHEN ValueTypeID in(7) then 'BANCONOTE_EUR' 
ELSE UPPER(ValueTypeName) end
order by 
case 
	when ValueTypeID = 2 then 1 
	when ValueTypeID = 1 then 3 
	when ValueTypeID = 22 then 4 
	when ValueTypeID = 3 then 2 
end
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAperturaTesoro] TO [SolaLetturaNoDanni]
GO
