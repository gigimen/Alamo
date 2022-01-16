SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [Snoopy].[vw_EntrateUscite]
as
select 
e.Gamingdate, 
e.EntrateTotali as Entrate, 
isnull(u.totuscite,0) as Uscite,
e.EntrateTotali - isnull(u.totuscite,0) as Presenze
FROM Reception.vw_EntrancesByGamingDate e
left outer join 
(

		SELECT GamingDate,sum(Increment) as totuscite 
		FROM Reception.tbl_Uscite
		group by GamingDate
		) u on u.gamingdate = e.GamingDate
GO
