SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_MensileAssegniCentax]
WITH SCHEMABINDING
AS
select 	top 100 percent
	CentaxCode,
	NrAssegno,
	GamingDate,
	EmissionTime as Ora,
   	CAST(EuroCents AS FLOAT) /100 AS Importo,
case when RedemCustTransID is null then 'Si' 
else 'No'
end as Negoziato,
case when RedemCustTransID is null then CAST(EuroCents AS FLOAT) /100  * 0.025 
else CAST(EuroCents AS FLOAT) /100  * 0.015
end as Commissione
from Snoopy.vw_AllAssegni
where --EmissionTime >= '6.1.2016 00:00' and  EmissionTime < '7.1.2016 00:00' and 
CentaxCode <> 'gu' 
and CentaxCode <> 'ng-c'
and CentaxCode <> 'ng'
order by EmissionTime




GO
