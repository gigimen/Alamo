SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [Accounting].[vw_CheckCashlessCHvTM]
WITH SCHEMABINDING
AS

select 	top 100 percent
	lf.Tag,
	lf.GamingDate,
	lf.DenoID,
	lf.FName as DenoName,
	lf.StockID,
	cht.SnapshotTimeLoc as CloseTime,
	IsNull(CH.AtCage,0) as AtCage,
	IsNull(TR.AtTerminal,0) as AtTerminal, 
	IsNull(CH.AtCage,0) - IsNull(TR.AtTerminal,0) as diff,
	isNull(SP.ShortPays,0) as ShortPays
from (
select l.LifeCycleID,
	l.GamingDate,
	l.Tag,
	l.StockID,
	d.DenoID,
	d.FName 
from Accounting.vw_AllStockLifeCycles l,CasinoLayout.tbl_Denominations d
where DenoID in (66,67) and StockTypeID  in(4,7)
) lf
inner join Accounting.vw_AllSnapshots cht on cht.LifeCycleID = lf.LifeCycleID and cht.SnapshotTypeID = 3 --only Chiusura snapshots
left outer join 
(
select  t.LifeCycleID,
	t.DenoID,
	sum(isnull(t.ImportoCents,0)) as AtTerminal
from Accounting.vw_AllCashlessTransactions t
group by t.LifeCycleID,
	t.DenoID
) TR on TR.LifeCycleID = lf.LifeCycleID and tr.DenoID = lf.DenoID 
left outer join 
(
select 	t.SourceLifeCycleID As LifeCycleID,
	t.DenoID,
	cast(isnull(t.Quantity,0)*(t.Denomination * 100) as int) as AtCage
from Accounting.vw_AllTransactionDenominations t	
where t.OpTypeID = 6 and  t.DenoID in (66,67)
) CH on CH.LifeCycleID = lf.LifeCycleID and ch.DenoID = lf.DenoID
left outer join 
(
select 	t.SourceLifeCycleID As LifeCycleID,
	cast(isnull(t.Quantity,0)*(t.Denomination * 100) as int) as ShortPays
from Accounting.vw_AllTransactionDenominations t	
where t.OpTypeID = 6 and  t.DenoID = 64
) SP on SP.LifeCycleID = lf.LifeCycleID
--where CH.AtCage is not null or TR.AtTerminal is not null
order by lf.StockID,lf.DenoID
GO
