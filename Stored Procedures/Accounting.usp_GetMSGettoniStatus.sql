SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Accounting].[usp_GetMSGettoniStatus] 
@MSlfid int
AS
if not exists (select LifeCycleID from Accounting.tbl_LifeCycles 
	where LifeCycleID = @MSlfid
	and StockID = 31
	)
begin
	raiserror('Invalid MainStock LifeCycleID (%d) specified',16,1,@MSlfid)
	return (1)
end
/*just for display purpose
select GamingDate 
from dbo.LifeCycles 
where LifeCycleID = @MSlfid
*/
/*QUERY FOR APERTURA
select 	DENO.DenoID,
	DENO.FDescription,
	AP.Quantity as Apertura
from dbo.Denominations DENO
left outer join Accounting.vw_AllSnapshotDenominations AP
on AP.DenoID = DENO.DenoID
and AP.OwnerUserGroupID = 13--IncassoMngGroupID
and AP.SnapshotTypeID = 5 --Conteggio Entrata
and AP.LifeCycleID = @MSlfid
where DENO.ValueTypeID = 1 and DENO.DenoID <> 10 --gettoni
*/


/*QUERY FOR CONSEGNATO
returns all consegnas accepted by this LifeCycleID
SELECT  CONS.DenoID,
	SUM(CONS.Quantity) as Consegnato 
	FROM Accounting.vw_AllTransactionDenominations CONS
	
	WHERE  CONS.OperationName = 'ConsegnaPerRipristino'
	AND CONS.DestLifeCycleID = @MSlfid
	AND CONS.ValueTypeID = 1 --only gettoni
	GROUP BY CONS.DenoID
*/

/*QUERY for all Ripristinato
--return all ripristino generate by MainStock to trolleys
SELECT  DenoID,
	SUM(Quantity) as Quantity 
	FROM Accounting.vw_AllTransactionDenominations
	WHERE  OperationName = 'Ripristino'
	--generate by Main Stock
	AND SourceLifeCycleID = @MSlfid
	AND ValueTypeID = 1 --only gettoni
	GROUP BY DenoID
*/

/*QUERY for ripristio MS
--return all ripristino generate by Incasso to MainStock
SELECT  DenoID,
	SUM(Quantity) as Quantity 
	FROM Accounting.vw_AllTransactionDenominations
	WHERE  OperationName = 'Ripristino'
	--generate by Main Stock
	AND DestLifeCycleID = @MSlfid
	AND ValueTypeID = 1 --only gettoni
	GROUP BY DenoID
*/





select a.DENOIDEx as DenoID,
	a.FDescriptionEx as FDescription,
	sum(a.Apertura) as Apertura,
	sum(a.Consegnato) as Consegnato,
	sum(a.Ripristinato) as Ripristinato,
	sum(a.RipMS) as RipMS,
	sum(a.CheckChiusura) as CheckChiusura,
	sum(a.Chiusura) as Chiusura
	from
(
select 	DENO.DenoID,
case when DENO.DenoID >=128 and DENO.DenoID <= 136 then DENO.DenoID - 127
else DENO.DenoID 
end as DENOIDEx,
	DENO.FDescription,
case when DENO.DenoID >=128 and DENO.DenoID <= 136 then (select FDescription from CasinoLayout.tbl_Denominations where DenoID = DENO.DenoID - 127)
else DENO.FDescription 
end as FDescriptionEx,
	IsNull(AP.Quantity,0) as Apertura,
	IsNull(CONS.Quantity,0) as Consegnato,
	IsNull(RIP.Quantity,0) as Ripristinato,
	IsNull(RIPMS.Quantity,0) as RipMS,
	IsNull(AP.Quantity,0) + IsNUll(CONS.Quantity,0) - IsNUll(RIP.Quantity,0) + IsNull(RIPMS.Quantity,0) as CheckChiusura,
	IsNull(CH.Quantity,0) as Chiusura
from CasinoLayout.tbl_Denominations DENO
left outer join (
	select DenoID,SUM(Quantity) as Quantity  
	FROM Accounting.vw_AllTransactionDenominations 
	WHERE  OperationName = 'ConsegnaPerRipristino'
	AND DestLifeCycleID = @MSlfid
	AND ValueTypeID in( 1,36) --only gettoni chf and euro
	GROUP BY DenoID
) as CONS
on DENO.DenoID = CONS.DenoID
left outer join Accounting.vw_AllSnapshotDenominations AP
on AP.DenoID = DENO.DenoID
and AP.OwnerUserGroupID = 13--IncassoMngGroupID
and AP.SnapshotTypeID = 5 --Conteggio Entrata
and AP.LifeCycleID = @MSlfid
left outer join (
	SELECT  DenoID,
		SUM(Quantity) as Quantity 
		FROM Accounting.vw_AllTransactionDenominations
		WHERE  OperationName = 'Ripristino'
		--generate by Main Stock
		AND SourceLifeCycleID = @MSlfid
		AND ValueTypeID in( 1,36) --only gettoni chf and euro
		GROUP BY DenoID
) as RIP
on DENO.DenoID = RIP.DenoID
left outer join (
	SELECT  DenoID,
		SUM(Quantity) as Quantity 
		FROM Accounting.vw_AllTransactionDenominations
		WHERE  OperationName = 'Ripristino'
		--accepted by Main Stock
		AND DestLifeCycleID = @MSlfid
		AND ValueTypeID in( 1,36) --only gettoni chf and euro
		GROUP BY DenoID
) as RIPMS
on DENO.DenoID = RIPMS.DenoID
left outer join Accounting.vw_AllSnapshotDenominations CH
on CH.DenoID = DENO.DenoID
and CH.SnapshotTypeID = 3 --Chiusura
and CH.LifeCycleID = @MSlfid
where DENO.ValueTypeID in(1,36) and DENO.DenoID not in (10,92,93,94) --avoid chips 500,soft count and riserva denos
) a
group by a.DENOIDEx,a.FDescriptionEx
order by a.denoidEx
GO
