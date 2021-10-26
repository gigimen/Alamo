SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Accounting].[vw_LGTableOpenHours]
WITH SCHEMABINDING
AS
select 
	lf.LifeCycleID,
	lf.GamingDate,
	s.StockID,
	s.tag,
	z.StateTime,
	case 
		when sum(z.TableOpen) > 0 then 1
		else 0
	end TableISOpen 
FROM  Accounting.tbl_LifeCycles lf 
	inner join CasinoLayout.Stocks s on s.StockID = lf.StockID
	inner join 
(
	SELECT 
			a.LifeCycleID
			,a.[StateTime]
			,a.DenoID
			,prec.StateTime as PrecTime
			,a.Quantity
			,prec.Quantity as PrecQuantity
			,case 
			when a.Quantity = isnull(prec.Quantity,0) then 0
			else	1
			end as TableOpen
	from
	(
	SELECT 
		p.LifeCycleID,
		p.DenoID,
		p.Quantity,
		p.StateTime
	FROM Accounting.tbl_Progress p
	where p.DenoID in (1,2,3,11,23,92,94)
	) a
	left outer join 
	(
	SELECT 
		p.LifeCycleID,
		p.DenoID,
		p.Quantity,
		p.StateTime
	FROM Accounting.tbl_Progress p
	where p.DenoID in (1,2,3,11,23,92,94)
	) prec on prec.LifeCycleID = a.LifeCycleID and prec.DenoID = a.DenoID and prec.StateTime = DATEADD(hh,-1,a.StateTime)
) z on z.LifeCycleID = lf.LifeCycleID
where s.StockTypeID = 1
group by 
	lf.LifeCycleID,
	lf.GamingDate,
	s.StockID,
	s.tag,
	z.StateTime






GO
