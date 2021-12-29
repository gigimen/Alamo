SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [ForIncasso].[usp_GetAperturaTesoroEx] 
@gaming			DATETIME
AS
---

if @gaming is null or @gaming = null
BEGIN
	--we always have to specify the gaming date 
	--otherwise we have troubles getting the previous close gaming date
	RAISERROR('Specify a valid Gaming Date',16,1)
	RETURN (1)
END




/*

DECLARE @gaming DATETIME

SET @gaming = '12.27.2021'


execute [ForIncasso].[usp_GetAperturaTesoroEx]   @gaming

--*/

declare @giornoprima datetime

set @giornoprima =  dateadd(day,-1,@gaming)

DECLARE @StockStatus TABLE(
Tag						VARCHAR(16)	NOT NULL,
StockTypeID				INT			NOT NULL,
StockID					INT			NOT NULL,
GamingDate				DATETIME	NOT NULL,
LastGamingDate			DATETIME,
LastLFID				INT,
maxLifeCycleSnapshotID	INT,
StockCompositionID		INT,
ChiusuraSnapshotID		INT,
CONTransactionID		INT,
RipSourceLifeCycleID	INT,
RipGamingDate			DATETIME,
RIPTransactionID		INT,
OraChiusura				DATETIME,
PRIMARY KEY (StockID,GamingDate) 
)

--insert chiusure casse del giorno prima
INSERT INTO @StockStatus
(
    Tag,
    StockTypeID,
    StockID,
    GamingDate,
    LastGamingDate,
    LastLFID,
    maxLifeCycleSnapshotID,
    StockCompositionID,
    ChiusuraSnapshotID,
    CONTransactionID,
    RipSourceLifeCycleID,
    RipGamingDate,
    RIPTransactionID,
    OraChiusura
)
/*

DECLARE @gaming DATETIME

SET @gaming = '12.27.2021'


declare @giornoprima datetime

set @giornoprima =  dateadd(day,-1,@gaming)


--*/
select 

	Tag						,
	StockTypeID				,
	StockID					,
	GamingDate				,
	LastGamingDate			,
	LastLFID				,
	maxLifeCycleSnapshotID	,
	StockCompositionID		,
	ChiusuraSnapshotID		,
	CONTransactionID		,
	RipSourceLifeCycleID	,
	RipGamingDate			,
	RIPTransactionID		,
	OraChiusura				
from [Accounting].[fn_GetStockLifeCycleInfo]  (@giornoprima,4) s

--insert CC del giorno prima
INSERT INTO @StockStatus
(
    Tag,
    StockTypeID,
    StockID,
    GamingDate,
    LastGamingDate,
    LastLFID,
    maxLifeCycleSnapshotID,
    StockCompositionID,
    ChiusuraSnapshotID,
    CONTransactionID,
    RipSourceLifeCycleID,
    RipGamingDate,
    RIPTransactionID,
    OraChiusura
)
select 

	Tag						,
	StockTypeID				,
	StockID					,
	GamingDate				,
	LastGamingDate			,
	LastLFID				,
	maxLifeCycleSnapshotID	,
	StockCompositionID		,
	ChiusuraSnapshotID		,
	CONTransactionID		,
	RipSourceLifeCycleID	,
	RipGamingDate			,
	RIPTransactionID		,
	OraChiusura				
from [Accounting].[fn_GetStockLifeCycleInfo]  (@giornoprima,7) 

/*
--insert MS del giorno prima
INSERT INTO @StockStatus
(
    Tag,
    StockTypeID,
    StockID,
    GamingDate,
    LastGamingDate,
    LastLFID,
    maxLifeCycleSnapshotID,
    StockCompositionID,
    ChiusuraSnapshotID,
    CONTransactionID,
    RipSourceLifeCycleID,
    RipGamingDate,
    RIPTransactionID,
    OraChiusura
)
select 

	Tag						,
	StockTypeID				,
	StockID					,
	GamingDate				,
	LastGamingDate			,
	LastLFID				,
	maxLifeCycleSnapshotID	,
	StockCompositionID		,
	ChiusuraSnapshotID		,
	CONTransactionID		,
	RipSourceLifeCycleID	,
	RipGamingDate			,
	RIPTransactionID		,
	OraChiusura				
from [Accounting].[fn_GetStockLifeCycleInfo]  (@giornoprima,2) 


--insert Riserva del giorno prima
INSERT INTO @StockStatus
(
    Tag,
    StockTypeID,
    StockID,
    GamingDate,
    LastGamingDate,
    LastLFID,
    maxLifeCycleSnapshotID,
    StockCompositionID,
    ChiusuraSnapshotID,
    CONTransactionID,
    RipSourceLifeCycleID,
    RipGamingDate,
    RIPTransactionID,
    OraChiusura
)
select 

	Tag						,
	StockTypeID				,
	StockID					,
	GamingDate				,
	LastGamingDate			,
	LastLFID				,
	maxLifeCycleSnapshotID	,
	StockCompositionID		,
	ChiusuraSnapshotID		,
	CONTransactionID		,
	RipSourceLifeCycleID	,
	RipGamingDate			,
	RIPTransactionID		,
	OraChiusura				
from [Accounting].[fn_GetStockLifeCycleInfo]  (@giornoprima,6) 
*/

--SELECT * FROM @StockStatus

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChiusureStocks%'
	)
begin
	print 'dropping #ChiusureStocks'
	DROP TABLE #ChiusureStocks
END

declare @Apertura as table (ValueTypeName varchar(32),Total int,timeLoc datetime)

--go with stock status
select
	s.Tag,
	s.StockTypeID,
	s.StockID,
	s.GamingDate,
	s.LastGamingDate,
	s.LastLFID,
	s.OraChiusura,
	s.RIPTransactionID,
	s.StockCompositionID,
	den.DenoID,
	den.FName as DenoName,
	den.Denomination,
	den.ValueTypeID,
	vt.FName											AS ValueTypeName,
	cu.CurrencyID,
	cu.IsoName											AS CurrencyAcronim,
	isnull((ch.Quantity),0)								as Chiusura,
	isnull((rip.Quantity),0)							as Ripristino,
	isnull(rip.ExchangeRate,1)							as RipExchangeRate
INTO #ChiusureStocks
FROM @StockStatus s 
inner join CasinoLayout.StockCompositions sc ON sc.StockCompositionID = s.StockCompositionID 
inner JOIN CasinoLayout.StockComposition_Denominations sd ON sc.StockCompositionID = sd.StockCompositionID 
inner JOIN CasinoLayout.tbl_Denominations den ON sd.DenoID = den.DenoID 
inner join CasinoLayout.tbl_ValueTypes vt on vt.ValueTypeID = den.ValueTypeID
INNER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = vt.CurrencyID

--inner join CasinoLayout.vw_allStockCompositions den on den.StockCompositionID = s.StockCompositionID
left outer	join [Accounting].[vw_AllSnapshotDenominations] ch on ch.LifeCycleSnapshotID = s.ChiusuraSnapshotID and den.DenoID = ch.DenoID
left outer	join [Accounting].[vw_AllTransactionDenominations] rip on rip.TransactionID = s.RIPTransactionID and den.DenoID = rip.DenoID
where den.ValueTypeID in (1,2,3,7,36,40,42) --gettoni chf,banconote chf,monete chf,euro,gettoni gioco euro,monete euro,gettoni euro

--select * from #ChiusureStocks order by StockID,DenoID

insert into @Apertura
select 
	case 
		WHEN s.ValueTypeID in(1,36,42) then 'GETTONI' 
		WHEN s.ValueTypeID IN(3,40) OR (s.ValueTypeID = 7 AND s.DenoID IN(137,138)) then 'MONETE'
		WHEN s.ValueTypeID = 2 OR (s.ValueTypeID = 7 AND s.DenoID NOT IN(137,138))  THEN 'BANCONOTE'
	else UPPER(ValueTypeName) end 
	+ '_' + s.CurrencyAcronim	AS ValueTypeName,
--	DenoID,
--	DenoName,
	sum((Chiusura + Ripristino)*Denomination),
	max(s.OraChiusura) as ChiusuraTime
from #ChiusureStocks s
group by 
	case 
		WHEN s.ValueTypeID in(1,36,42) then 'GETTONI' 
		WHEN s.ValueTypeID IN(3,40) OR (s.ValueTypeID = 7 AND s.DenoID IN(137,138)) then 'MONETE'
		WHEN s.ValueTypeID = 2 OR (s.ValueTypeID = 7 AND s.DenoID NOT IN(137,138))  THEN 'BANCONOTE'
	else UPPER(ValueTypeName) end 
	+ '_' + s.CurrencyAcronim	

--SELECT * FROM @Apertura


/*
group by cont.Tag,
		cont.StockID,
		s.ReopenGamingDate,
		s.GamingDate*/

		--order by cont.StockID

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChiusureStocks%'
	)
BEGIN
	PRINT 'dropping #ChiusureStocks'
	DROP TABLE #ChiusureStocks
END

INSERT INTO @Apertura
SELECT	'DEPOSITI_CHF' 
		,ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination),0)		AS Total
		,MAX(DepOn.[CustomerTransactionTime]) AS DepOnTimeLoc
FROM  Snoopy.tbl_Depositi dep
	INNER JOIN  Snoopy.tbl_CustomerTransactions DepOn ON dep.DepoCustTransID = DepOn.CustomerTransactionID AND DepOn.CustTrCancelID IS NULL
	INNER JOIN Accounting.tbl_LifeCycles DepOnLF ON DepOnLF.LifeCycleID = DepOn.SourceLifeCycleID 
	INNER JOIN Snoopy.tbl_CustomerTransactionValues DepOnValues ON DepOnValues.CustomerTransactionID = DepOn.CustomerTransactionID 
	INNER JOIN CasinoLayout.tbl_Denominations DepOnDenos ON DepOnValues.DenoID = DepOnDenos.DenoID
	INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = DepOnDenos.ValueTypeID
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactions DepOff	ON dep.PrelevCustTransID = DepOff.CustomerTransactionID AND DepOff.CustTrCancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_LifeCycles DepOffLF ON DepOffLF.LifeCycleID = DepOff.SourceLifeCycleID 
WHERE DepOn.CustTrCancelID IS NULL AND DepOnLF.GamingDate < @gaming
AND (
		dep.PrelevCustTransID IS NULL --still have to be prelevata 
		OR
		DepOffLF.GamingDate >= @gaming --prelevate today
	)
AND vt.CurrencyID = 4

INSERT INTO @Apertura
SELECT	'DEPOSITI_EUR'
		,ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination),0)		AS Total
		,MAX(DepOn.[CustomerTransactionTime]) AS DepOnTimeLoc
--from Snoopy.vw_allDepositi 
FROM  Snoopy.tbl_Depositi dep
	INNER JOIN  Snoopy.tbl_CustomerTransactions DepOn ON dep.DepoCustTransID = DepOn.CustomerTransactionID AND DepOn.CustTrCancelID IS NULL
	INNER JOIN Accounting.tbl_LifeCycles DepOnLF ON DepOnLF.LifeCycleID = DepOn.SourceLifeCycleID 
	INNER JOIN Snoopy.tbl_CustomerTransactionValues DepOnValues ON DepOnValues.CustomerTransactionID = DepOn.CustomerTransactionID 
	INNER JOIN CasinoLayout.tbl_Denominations DepOnDenos ON DepOnValues.DenoID = DepOnDenos.DenoID
	INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = DepOnDenos.ValueTypeID
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactions DepOff	ON dep.PrelevCustTransID = DepOff.CustomerTransactionID AND DepOff.CustTrCancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_LifeCycles DepOffLF ON DepOffLF.LifeCycleID = DepOff.SourceLifeCycleID 
WHERE DepOn.CustTrCancelID IS NULL AND DepOnLF.GamingDate < @gaming
AND (
		dep.PrelevCustTransID IS NULL --still have to be prelevata 
		OR
		DepOffLF.GamingDate >= @gaming --prelevate today
	)
AND vt.CurrencyID = 0

SELECT * FROM @Apertura
GO
