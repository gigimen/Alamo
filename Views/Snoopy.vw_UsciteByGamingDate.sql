SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [Snoopy].[vw_UsciteByGamingDate]
AS
SELECT 
		case 
			when u.[SiteID] = 51 then 'Tappeto Veto2'
			when u.[SiteID] = 52 then 'Fotocellula Sfizio'
			else s.FName end as Registatore
      ,[GamingDate]
      ,min([TimestampLoc])	as PimaUscita
      ,max([TimestampLoc])	as UltimaUscita
      ,count(*)				as TotRegistrazioni
	  ,sum(case when [Increment] >0 then 1 else 0 end)	as PosUscite
	  ,sum(case when [Increment] <0 then 1 else 0 end)	as NegUscite
	  ,sum([Increment])		as TotUscite
FROM Reception.tbl_Uscite u
inner join CasinoLayout.Sites s on s.SiteID = u.SiteID
group by  case 
			when u.[SiteID] = 51 then 'Tappeto Veto2'
			when u.[SiteID] = 52 then 'Fotocellula Sfizio'
			else s.FName end
      ,[GamingDate]
	--order by gamingdate
GO
