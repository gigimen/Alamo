SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [Accounting].[usp_GetApertura] 
@lfID int
AS

declare @ret int
	,@StockID int
	,@StockTypeID int
	,@gaming datetime
	,@prevlfID int
	,@prevgaming datetime
	,@ultimorestime datetime
	,@penultimoRestime datetime
	,@ultimores int
	,@penultimores int
	,@incremento int


if not exists ( select StockID from Accounting.tbl_LifeCycles where LifeCycleID = @lfID)
begin
	raiserror('Invalid LifeCycleID (%d)',16,1,@lfID)
	return 1
end


select 
	@gaming = l.GamingDate,
	@StockID = l.StockID ,
	@StockTypeID = s.StockTypeID
from Accounting.tbl_LifeCycles l
inner join CasinoLayout.Stocks s on s.StockID = l.StockID
where LifeCycleID = @lfID

if @StockTypeID = 1 --only for tables
begin
	execute @ret = [Accounting].[usp_GetTableLastResult] 
		@lfID 
		,@ultimorestime  output
		,@penultimoRestime  output
		,@ultimores  output
		,@penultimores  output
		,@incremento  output
	if @ret <> 0 
	begin
		raiserror('Error getting last table result (%d)',16,1,@ret)
		return @ret
	end
end
	


select 
@prevlfID = lf.LifeCycleID,
@prevgaming = lf.GamingDate
from Accounting.tbl_LifeCycles	lf
inner join Accounting.tbl_Snapshots ss on lf.LifeCycleID = ss.LifeCycleID
where StockID = @StockID 
and GamingDate in
( 
		select max(GamingDate) 
		from Accounting.tbl_Snapshots ss
		inner join Accounting.tbl_LifeCycles lf on lf.LifeCycleID = ss.LifeCycleID
		where lf.StockID = @StockID 
		and lf.GamingDate < @gaming 
		and ss.SnapshotTypeID = 3 --Chiusura
		and ss.LCSnapShotCancelID is null
)
and ss.SnapshotTypeID = 1 --apertura has not been canceled
and ss.LCSnapShotCancelID is null
--print @prevlfID

select 	
	a.StockID,
	a.Tag,
	a.PrevGamingDate,
	a.PrevChiusura,
	a.Consegna,
	a.Ripristino,
	a.Apertura,
	IsNull(b.Acconti,0) as Acconti,
	IsNull(c.Versamenti,0) as Versamenti,
	@ultimorestime							as UltimoResTime,
	@ultimores								as UltimoRisultato,
	@penultimores							as PenultimoRisultato,
	@incremento								as Incremento
from 
( 
--calculate Last Chiusura, Consegna and ripristino and, consequentely next apertura
select 
	pch.StockID, 
	pch.Tag,
	pch.GamingDate as PrevGamingDate,
	sum(IsNull(pch.Chiusura,0) * pch.Denomination) as PrevChiusura,
	sum(IsNull(pch.Consegna,0) * pch.Denomination)  as Consegna,
	sum(IsNull(pch.Ripristino,0) * pch.Denomination)  as Ripristino,
	sum(IsNull(pch.Ripristinato,0) * pch.Denomination)  as Apertura
from Accounting.vw_AllChiusuraConsegnaDenominations pch
where pch.LifeCycleID = @prevlfid and pch.ValueTypeID IN (1,36,42) --count only chips CHF and chips gioco EUR and chips EUR
group by 
	pch.StockID, 
	pch.Tag,
	pch.GamingDate
) a
left outer join (
--sum up all acconti
select 
	SourceTag,
	SourceStockID as StockID,
	sum(TotalForSource) as Acconti 
from Accounting.vw_AllTransactions acc 
where acc.SourceLifeCycleID = @lfid 
	and acc.OpTypeID = 1 
	and acc.DestLifeCycleID is not null -- accepted Acconti
group by SourceTag,SourceStockID
) b on b.StockID = a.StockID 
left outer join (
--sum up all versamenti
select 
	SourceTag,
	SourceStockID as StockID,
	sum(TotalForSource) as Versamenti 
from Accounting.vw_AllTransactions ver 
where ver.SourceLifeCycleID = @lfid 
	and ver.OpTypeID = 4 
	and ver.DestLifeCycleID is not null -- accepted Versamenti
group by SourceTag,
SourceStockID
) c on c.StockID = a.StockID
GO
