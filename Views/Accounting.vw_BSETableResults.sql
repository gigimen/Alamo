SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Accounting].[vw_BSETableResults]
WITH SCHEMABINDING
as

select 

	lf.GamingDate,
	sum(cast(p.Quantity as float))* 1000.0 as BSE
FROM    Accounting.tbl_Progress p
inner join (
SELECT LifeCycleID
      ,max([StateTime]) as maxtime
FROM Accounting.tbl_Progress
where denoid = 23
group by LifeCycleID
) ch on ch.LifecycleId = p.LifecycleId and ch.maxtime = p.[StateTime] and p.denoid = 23
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = ch.LifeCycleID 
group by lf.GamingDate






GO
