SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_ChipsMovementReport]
@gaming DATETIME
AS


/*
DECLARE @gaming DATETIME

SET @gaming = '1.1.2017'

*/


--this temporary table stores last chiusura snapshots id of all tables at the specified GamingDate
IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChipsRipristinati%'
	)
begin
	print 'dropping #ChipsRipristinati'
	DROP TABLE #ChipsRipristinati
END

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#StockStatus%'
	)
begin
	print 'dropping #StockStatus'
	DROP TABLE #StockStatus
END

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChipsReport%'
	)
begin
	print 'dropping #ChipsReport'
	DROP TABLE #ChipsReport
END


--go with stock status
select
	s.Tag,
	s.FName,
	s.StockTypeID,
	s.StockID,
	s.MinBet,
	lc.LifeCycleID AS LastCloseLFID,
	lc.CloseSnapshotID AS maxLifeCycleSnapshotID,
	lf.LifeCycleID,
	lf.GamingDate,
	lf.StockCompositionID
--let start from the active stocks
INTO #StockStatus
FROM CasinoLayout.Stocks s 
INNER  join [Accounting].[fn_GetLastLifeCycleByStockType](@gaming,NULL) lc on lc.StockId = s.StockID 
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = lc.LifeCycleID
WHERE s.StockTypeID IN (1,2,4,5,6,7) --tavoli,trolleys,cc,ms,riserva,e incasso
AND @gaming >= s.FromGamingDate 
AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS null) 

--SELECT * FROM #StockStatus

select
	s.Tag,
	s.FName,
	s.StockTypeID,
	s.StockID,
	s.MinBet,
	s.LastCloseLFID,
	s.maxLifeCycleSnapshotID,
	s.LifeCycleID,
	s.GamingDate,
	d.ValueTypeID,
	d.FDescription,
	d.DenoID,
	d.Denomination,
	sc.IsRiserva,
	sc.InitialQty,
	sc.WeightInTotal,
	sc.ModuleValue,
	chV.LifeCycleSnapshotID			AS ChiusuraSSID,
	ch.SnapshotTimeLoc 				AS CloseTime,
	ISNULL(chV.Quantity,0)			AS Chiusura,
	ISNULL(chV.ExchangeRate,0.0) 	AS ERChiusura,
	conV.TransactionID				AS ConsegnaTRID,
	ISNULL(conV.Quantity,0) 		AS Consegna,
	ISNULL(conV.ExchangeRate,0) 	AS ERConsegna,
	ripV.TransactionID				AS RipristinoTRID,
	ISNULL(ripV.Quantity,0)			AS Ripristino,
	ISNULL(ripV.ExchangeRate,0)		AS ERRipristino,
	CASE 
	WHEN s.StockTypeID = 1 AND s.GamingDate < '3.23.2017' THEN
		--before big change chiusura included also consegna 
		ISNULL(chV.Quantity,0) - ISNULL(conV.Quantity,0) + ISNULL(ripV.Quantity,0) 
	WHEN s.StockTypeID = 2 THEN
		--for mainstock chiusura include also ripristino
		ISNULL(chV.Quantity,0) 
	ELSE
		--for all others the we have to sum what was left in the stock with what is in ripristino
		ISNULL(chV.Quantity,0) + ISNULL(ripV.Quantity,0) 
	END AS Ripristinato
--let's start from the active stocks
INTO #ChipsRipristinati
FROM #StockStatus s 
INNER JOIN CasinoLayout.StockComposition_Denominations sc	ON sc.StockCompositionID = s.StockCompositionID
INNER JOIN CasinoLayout.tbl_Denominations d	ON d.DenoID = sc.DenoID

--left outer join Accounting.vw_AllSnapshots ch on ch.LifeCycleID = lf.LifeCycleID and
LEFT OUTER JOIN Accounting.tbl_Snapshots ch ON ch.LifeCycleID = s.LifeCycleID AND ch.SnapshotTypeID = 3 AND ch.LCSnapShotCancelID IS NULL
LEFT OUTER JOIN Accounting.tbl_SnapshotValues chV ON  chV.LifeCycleSnapshotID = ch.LifeCycleSnapshotID	
		AND sc.DenoID = chV.DenoID 

--THEN CONSEGNA VALUES
--use left join to include also consegna with Denomination with zero values
LEFT OUTER JOIN Accounting.vw_AllTransactionDenominations conV ON conV.SourceLifeCycleID = s.LifeCycleID  
	AND conV.OpTypeID = 6 --consegna
	AND conV.DenoID = sc.DenoID
	
--FINALLY RIPRISTINO
--use left join to include also ripristino with Denomination with zero values
LEFT OUTER JOIN Accounting.vw_AllTransactions rip ON rip.DestStockID = s.StockID 
	AND rip.SourceGamingDate = s.GamingDate
	AND rip.OpTypeID = 5 --ripristino
LEFT OUTER JOIN Accounting.tbl_TransactionValues ripV ON ripV.TransactionID = rip.TransactionID 
	AND ripV.DenoID = sc.DenoID
WHERE sc.IsRiserva = 0 
AND d.ValueTypeID IN(1,36) --solo i gettoni sfr ed euro
and	s.StockTypeID IN (1,2,4,5,6,7) --tavoli,trolleys,cc,ms,riserva,e incasso

 
--format the last chiusura values into another temporary table
select 	
	s.Tag,
	s.StockID,
	s.StockTypeID,
	s.GamingDate,
	IsNull(C10000.Ripristinato,0) 	as Chips10000,
	IsNull(C5000.Ripristinato,0)	as Chips5000,
	IsNull(C1000.Ripristinato,0)	as Chips1000,
	IsNull(C100.Ripristinato,0) 	as Chips100,
	IsNull(C50.Ripristinato,0) 		as Chips50,
	IsNull(C20.Ripristinato,0) 		as Chips20,
	IsNull(C10.Ripristinato,0) 		as Chips10,
	IsNull(C5.Ripristinato,0) 		as Chips5,
	IsNull(C1.Ripristinato,0) 		as Chips1,
	IsNull(LC.Ripristinato,0) 		as LuckyChips,
	IsNull(C10000.Ripristinato,0) 	* 10000 +
	IsNull(C5000.Ripristinato,0)	* 5000 +
	IsNull(C1000.Ripristinato,0)	* 1000 +
	IsNull(C100.Ripristinato,0) 	* 100 +
	IsNull(C50.Ripristinato,0) 		* 50 +
	IsNull(C20.Ripristinato,0) 		* 20 +
	IsNull(C10.Ripristinato,0) 		* 10 +
	IsNull(C5.Ripristinato,0) 		* 5 +
	IsNull(C1.Ripristinato,0) 		* 1 AS TotalValue
INTO #ChipsReport
FROM #StockStatus s 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 1,128) group by StockID) C10000	ON C10000.StockID = s.StockID
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 2,129)	group by StockID) C5000		ON C5000.StockID = s.StockID 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 3,130)	group by StockID) C1000		ON C1000.StockID = s.StockID 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 4,131) group by StockID) C100		ON C100.StockID = s.StockID 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 5,132) group by StockID) C50		ON C50.StockID = s.StockID 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 6,133) group by StockID) C20		ON C20.StockID = s.StockID 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 7,134) group by StockID) C10		ON C10.StockID = s.StockID 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 8,135) group by StockID) C5		ON C5.StockID = s.StockID 
left outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID IN( 9,136) group by StockID) C1		ON C1.StockID = s.StockID 
LEFT outer join (select StockID,sum(isnull(Ripristinato,0)) as Ripristinato from #ChipsRipristinati where DenoID = 78		group by StockID) LC		ON LC.StockID = s.StockID 

select 	
		case when StockTypeID = 1 then 'tavoli' else 'cassa' end as Tag,
	    MAX(GamingDate) AS GamingDate,
		sum(Chips10000	) as Chips10000	,
		sum(Chips5000	) as Chips5000	,
		sum(Chips1000	) as Chips1000	,
		sum(Chips100	) as Chips100	,
		sum(Chips50		) as Chips50		,
		sum(Chips20		) as Chips20		,
		sum(Chips10		) as Chips10		,
		sum(Chips5		) as Chips5		,
		sum(Chips1		) as Chips1		,
		sum(LuckyChips	) as LuckyChips	,
		sum(TotalValue	) as TotalValue	
	FROM #ChipsReport
	group by case when StockTypeID = 1 then 'tavoli' else 'cassa' end
UNION ALL
	SELECT 	'Totale Quantità' AS Tag,
	    MAX(GamingDate) AS GamingDate,
		SUM(Chips10000)  AS Chips10000,
		SUM(Chips5000)  AS Chips5000,
		SUM(Chips1000) AS Chips1000,
		SUM(Chips100)  AS Chips100,
		SUM(Chips50)   AS Chips50,
		SUM(Chips20)  AS Chips20,
		SUM(Chips10)   AS Chips10,
		SUM(Chips5)		AS Chips5,
		SUM(Chips1)		AS Chips1,
		SUM(LuckyChips)	AS LuckyChips,
		0				as TotalValue
	FROM #ChipsReport
UNION ALL
	SELECT 	'Totale CHF' AS Tag,
	    MAX(GamingDate) AS GamingDate,
		SUM(Chips10000) * 10000 AS Chips10000,
		SUM(Chips5000) * 5000  AS Chips5000,
		SUM(Chips1000) * 1000  AS Chips1000,
		SUM(Chips100) * 100  AS Chips100,
		SUM(Chips50) * 50  AS Chips50,
		SUM(Chips20) * 20  AS Chips20,
		SUM(Chips10) * 10  AS Chips10,
		SUM(Chips5) * 5  AS Chips5,
		SUM(Chips1) * 1  AS Chips1,
		0				AS LuckyChips,
		Sum(TotalValue) as TotalValue
	FROM #ChipsReport
--get rid of temporary tables



--this temporary table stores last chiusura snapshots id of all tables at the specified GamingDate
IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChipsRipristinati%'
	)
begin
	print 'dropping #ChipsRipristinati'
	DROP TABLE #ChipsRipristinati
END

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#StockStatus%'
	)
begin
	print 'dropping #StockStatus'
	DROP TABLE #StockStatus
END

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#ChipsReport%'
	)
begin
	print 'dropping #ChipsReport'
	DROP TABLE #ChipsReport
END
GO
