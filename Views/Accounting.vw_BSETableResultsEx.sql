SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Accounting].[vw_BSETableResultsEx]
WITH SCHEMABINDING
as

select 
	lf.GamingDate,
	d.DenoID,
	d.FName as denoName,
	sum(cast(p.Quantity as float))* 1000.0 as Finale
FROM    Accounting.tbl_Progress p
inner join (
SELECT LifeCycleID,denoid
      ,max([StateTime]) as maxtime
FROM Accounting.tbl_Progress
where denoid in (11,23)
group by LifeCycleID,denoid
) ch on ch.LifecycleId = p.LifecycleId and ch.maxtime = p.[StateTime] and p.denoid = ch.DenoID
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = ch.LifeCycleID 
inner join CasinoLayout.tbl_Denominations d on d.DenoID = ch.DenoID
group by lf.GamingDate,d.DenoID,d.FName







GO
