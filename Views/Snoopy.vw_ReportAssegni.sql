SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_ReportAssegni]
WITH SCHEMABINDING
AS
select top 100 percent 
GamingDate,
Importo,
Totale,
Negoziato,
Commissione
from
(
		select 
			GamingDate,
			sum(CHF)as Importo,
			count(*) as Totale,
			'Y' as Negoziato,
			sum(CHF *0.25) as Commissione
		from Snoopy.vw_AllAssegni
		where redemlfid is null
		group by GamingDate
	union all
		select 	top 100 percent
			GamingDate,
			sum(CHF) as Importo,
			count(*) as Totale,
			'N' as Negoziato,
			sum(CHF *0.15) as Commissione
		from Snoopy.vw_AllAssegni
		where redemlfid is not null
		group by GamingDate
) ff
order by GamingDate









GO
