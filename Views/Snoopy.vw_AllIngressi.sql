SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_AllIngressi]
WITH SCHEMABINDING
AS
SELECT  
	e.GamingDate, 
	e.Entrances, 
	e.Visite,
	e.GoldenClub, 
	e.GoldenClubUno, 
	e.Membri,
	e.MembriUno,
	ev.Nome,
	case 
	when ev.TotPartecipazioni is null then
		cast(ev.Members as varchar(16))
	else
		cast(ev.TotPartecipazioni as varchar(16)) + '(' +cast(ev.Members as varchar(16)) +')' 
	end as TotPartecipazioni
FROM    Snoopy.tbl_EntrateSummary e
LEFT OUTER JOIN 
(
select 
	e.Nome,
	e.GamingDate,
	count(*) as Members,
	--count(distinct CustomerID) as Members,
	--sum(g.Accompagnatori) + count(distinct CustomerID)  as TotPartecipazioni 
	sum(g.Accompagnatori) + count(*)  as TotPartecipazioni 
	
from GoldenClub.tbl_PartecipazioneEventi g
INNER JOIN [Marketing].[tbl_Eventi] e on e.EventoID = g.EventoID 
group by e.EventoID,e.Nome,e.GamingDate
			
) ev ON e.GamingDate = ev.GamingDate
GO
