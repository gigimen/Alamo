SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [Accounting].[usp_TableChipsReport] 
@fromDate datetime
AS

--declare @fromDate DATETIME
--SET @fromDate = '6.27.2013'
--this temporary table stores all last chiusure
--life cycles informations for all Stocks
IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#TmpTableLastGamingDate%'
	)
begin
--	print 'dropping #TmpTableLastGamingDate'
	DROP TABLE #TmpTableLastGamingDate
end



select 
	st.Tag,
	st.StockID,
	st.StockTypeID,
	lf.LifeCycleID,
	st.MinBet,
	Accounting.fn_GetLastGamingDate(st.StockID,1,@fromDate) as CloseGamingDate,
	CHSS.LifeCycleSnapshotID	as CloseSnapshotID,
	con.TransactionID			as ConsegnaTransID,
	rip.TransactionID			as RipristinoTransID,
	myrip.TransactionID			as MyRipristinoID
into #TmpTableLastGamingDate
from CasinoLayout.Stocks st
inner join Accounting.tbl_LifeCycles lf on lf.StockID = st.StockID and lf.GamingDate = Accounting.fn_GetLastGamingDate(st.StockID,1,@fromDate)
--with a valid open snapshot
inner join Accounting.tbl_Snapshots OPSS on OPSS.LifeCycleID = lf.LifeCycleID and OPSS.SnapshotTypeID = 1 and OPSS.LCSnapShotCancelID is null

--mark Chiusura snapshot
LEFT OUTER JOIN Accounting.tbl_Snapshots CHSS 
ON CHSS.LifeCycleID = lf.LifeCycleID
AND CHSS.SnapshotTypeID = 3 --Chiusura

--look for Consegna
left outer join Accounting.tbl_Transactions con 
on lf.LifeCycleID = con.SourceLifeCycleID 
and con.OpTypeID = 6 --Consegna
and con.TrCancelID is null

--look for my ripristino
left outer join Accounting.tbl_Transactions myrip 
on lf.LifeCycleID = myrip.DestLifeCycleID 
and myrip.OpTypeID = 5 --ripristino
and myrip.TrCancelID is null

--look also for ripristino after my Consegna
--look for transactions of type ripristino whose source lfid is the destlfid of some transaction (the Consegna) for which
--the StockID was the source  
--the rispristion has been created for me the same GamingDate by Mainstock
left outer join Accounting.vw_AllTransactions rip 
on rip.SourceLifeCycleID = con.DestLifeCycleID and LF.StockID = rip.DestStockID and rip.OpTypeID = 5 --only ripristino operations 
and rip.TrCancelID is null

where st.StockTypeID = 1  -- only tables
and st.[FromGamingDate] <= @fromDate 
and (st.TillGamingDate is null or st.TillGamingDate >= @fromDate)


/*
select * from #TmpTableLastGamingDate
return 0

*/

--we want to know how all stock will be 
--after being ripristinated therefore we have to return 
--all ripristino Denominations create that gaming date or still pending
--(i.e. trolley has not been opened that gaming date)
-- plus all last chiusure of Stocks
select 
	a.OperationName,
	a.Tag,
	a.StockID,
	a.StockTypeID,
	a.MinBet,
	a.GamingDate,
	a.DenoID,
	a.DenoName,
	a.Quantity,
	a.TransactionID
from
(

select 'Ripristino' 							as OperationName,
	lg.Tag 										,
	lg.StockID									,
	lg.StockTypeID								,
	lg.MinBet									,
	SourceGamingDate 							as GamingDate,
	DenoID,
	FDescription								as DenoName,
	Quantity,
	lg.RipristinoTransID						as TransactionID
	from #TmpTableLastGamingDate lg 
	LEFT OUTER join Accounting.vw_AllTransactionDenominations rip
	--look for the ripristino created for the last known Chiusura
	-- therefore we have to join on the same stock 
	on lg.RipristinoTransID = rip.TransactionID 
	where [OpTypeID] = 5 --'Ripristino'
	and ValueTypeID in(1,36) --Gettoni euro e sfr
	--avoid reporting ripristions with no values
	and DenoID is not null

UNION ALL


select 'Consegna' 							as OperationName,
	SourceTag								as Tag,
	lg.StockID								as StockID,
	lg.StockTypeID							as StockTypeID,
	lg.MinBet								as MinBet,
	SourceGamingDate 						as GamingDate,
	DenoID,
	FDescription							as DenoName,
	Quantity,
	lg.ConsegnaTransID						as TransactionID
	from #TmpTableLastGamingDate lg 
	LEFT outer join Accounting.vw_AllTransactionDenominations con
	--look for the ripristino created for the last known Chiusura
	-- therefore we have to join on the same stock 
	on lg.ConsegnaTransID = con.TransactionID
	where [OpTypeID] = 6 --'ConsegnaPerRipristino'
	and ValueTypeID in(1,36) --Gettoni euro e sfr
	--avoid reporting ripristions with no values
	and DenoID is not null

UNION ALL

--all last chiusure
select 'Chiusura' 		as OperationName,
	lc.Tag				as Tag,
	lc.StockID			as StockID,
	lc.StockTypeID		as StockTypeID,
	lc.MinBet			as MinBet,
	lc.CloseGamingDate	as GamingDate,
	DenoID,
	FDescription		as DenoName,
	Quantity,
	lc.CloseSnapshotID	as TransactionID
	from #TmpTableLastGamingDate lc
	LEFT outer join Accounting.vw_AllSnapshotDenominations
	on Accounting.vw_AllSnapshotDenominations.LifeCycleSnapshotID = lc.CloseSnapshotID
	where ValueTypeID in(1,36) --Gettoni euro e sfr
/*
--	order by #TmpTableLastChiusuraSnapshot.StockID desc,DenoID desc
UNION ALL
select 'StatoInizialeRiserva' 				as OperationName,
	lc.Tag				as Tag,
	lc.StockID			as StockID,
	lc.StockTypeID		as StockTypeID,
	lc.MinBet			as MinBet,
	lc.CloseGamingDate	as GamingDate,
	DenoID,
	FDescription							as DenoName,
	[Accounting].[fn_TableCalculateChiusuraRiserva] (
				[DenoID],
				[Chiusura],--+[Consegna],
				[InitialQty],
				[moduleValue]/*,
				default */)					as Quantity
  FROM  #TmpTableLastGamingDate lc
	LEFT outer join [Accounting].[vw_AllChiusuraConsegnaDenominations] ccd
	--look for the ripristino created for the last known Chiusura
	-- therefore we have to join on the same stock 
	on lc.LifeCycleID = ccd.LifeCycleID 
	where ValueTypeID in(1,36) --Gettoni euro e sfr
	--avoid reporting ripristions with no values
	and DenoID is not null
	*/

) a

order by a.OperationName,a.DenoID asc,a.StockID asc

IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#TmpTableLastGamingDate%'
	)
begin
--	print 'dropping #TmpTableLastGamingDate'
	DROP TABLE #TmpTableLastGamingDate
end
GO
GRANT EXECUTE ON  [Accounting].[usp_TableChipsReport] TO [SolaLetturaNoDanni]
GO
