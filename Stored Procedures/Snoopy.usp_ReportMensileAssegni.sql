SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Snoopy].[usp_ReportMensileAssegni] 
@mese int
AS
if @mese < 1 or @mese > 12
begin
	raiserror('Wrong Mounth number specified. Mubst be betwwen 1 and 12',16,1)
	return 1
end



select 	CentaxCode,
	EmissionTime as Ora,
   	CAST(EuroCents AS FLOAT) /100 AS Importo,
case when RedemCustTransID is null then 'Si' 
else 'No'
end as Negoziato,
case when RedemCustTransID is null then CAST(EuroCents AS FLOAT) /100  * 0.025 
else CAST(EuroCents AS FLOAT) /100  * 0.015
end as Commissione

from Snoopy.vw_AllAssegni
where DatePart(month,EmissionTime) = @mese
order by EmissionTime

GO
