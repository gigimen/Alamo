SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [GoldenClub].[vw_AllIngressi]
WITH SCHEMABINDING
AS
SELECT  
	e.GamingDate, 
	e.Entrances, 
	e.GoldenClub, 
	e.GoldenClubUno, 
	e.Membri,
	e.MembriUno,
	ev.Nome,
	CASE 
	WHEN ev.TotPartecipazioni IS NULL THEN
		CAST(ev.Members AS VARCHAR(16))
	ELSE
		CAST(ev.TotPartecipazioni AS VARCHAR(16)) + '(' +CAST(ev.Members AS VARCHAR(16)) +')' 
	END AS TotPartecipazioni
FROM    Snoopy.tbl_EntrateSummary e
LEFT OUTER JOIN 
(
SELECT 
	e.Nome,
	e.GamingDate,
	COUNT(*) AS Members,
	--count(distinct CustomerID) as Members,
	--sum(g.Accompagnatori) + count(distinct CustomerID)  as TotPartecipazioni 
	SUM(g.Accompagnatori) + COUNT(*)  AS TotPartecipazioni 
	
FROM GoldenClub.tbl_PartecipazioneEventi g
INNER JOIN [Marketing].[tbl_Eventi] e ON e.EventoID = g.EventoID 
GROUP BY e.EventoID,e.Nome,e.GamingDate
			
) ev ON e.GamingDate = ev.GamingDate
GO
