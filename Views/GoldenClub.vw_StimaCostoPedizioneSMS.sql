SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [GoldenClub].[vw_StimaCostoPedizioneSMS]
as
select 
	a.EventoID,
	a.[Nome],
	a.GamingDate,
	a.smsInvito,
	a.lunghezza,
	a.lung,
	CASE 
	WHEN a.DragonAndGolden = 0 THEN 'solo golden'
	WHEN a.DragonAndGolden = 2 THEN 'solo dragon'
	WHEN a.DragonAndGolden = 1 THEN 'sia dragon che golden'
	ELSE null 
	END as Tipo,
	CASE 
	WHEN a.DragonAndGolden = 0 THEN g.tot --solo golden
	WHEN a.DragonAndGolden = 2 THEN d.tot --solo dragon
	WHEN a.DragonAndGolden = 1 THEN g.tot + d.tot --sia dragon che golden
	ELSE 0 
	END as numClienti,
	CASE 
	WHEN a.DragonAndGolden = 0 THEN g.tot * a.lung * 1.75 --solo golden
	WHEN a.DragonAndGolden = 2 THEN d.tot  * a.lung * 1.75--solo dragon
	WHEN a.DragonAndGolden = 1 THEN (g.tot + d.tot ) * a.lung * 1.75--sia dragon che golden
	ELSE 0 
	END as Crediti, 
	CASE 
	WHEN a.DragonAndGolden = 0 THEN g.tot * a.lung * 1.75 * 0.06 --solo golden
	WHEN a.DragonAndGolden = 2 THEN d.tot  * a.lung * 1.75 * 0.06 --solo dragon
	WHEN a.DragonAndGolden = 1 THEN (g.tot + d.tot ) * a.lung * 1.75 * 0.06 --sia dragon che golden
	ELSE 0 
	END as CostoCHF
	from
	(
		select EventoID,[Nome],GamingDate,smsInvito,len(smsinvito) as lunghezza,
		case
		when len(smsinvito) > 480 then 4
		when len(smsinvito) > 320 then 3
		when len(smsinvito) > 160 then 2
		else 1
		end as lung,
		[DragonAndGolden]
	  from Marketing.tbl_Eventi
  ) a,
  (
	  SELECT count(*) as tot
			FROM GoldenClub.vw_AllGoldenMembers g
			where g.gcCancelID is null
			and g.ConsegnaCarta is not null
			and g.SMSNumber is not null
			and g.GoldenParams & 2 = 2   --SMSNumberChecked,
			and g.GoldenParams & 1 = 0   --SMSNumberDisabled,
			and g.GoldenParams & 32 = 32 --invito eventi enabled
 ) g,
  (
	  SELECT count(*) as tot
			FROM GoldenClub.vw_AllDragonMembers g
			where g.gcCancelID is null
			and g.ConsegnaCarta is not null
			and g.SMSNumber is not null
			and g.GoldenParams & 2 = 2   --SMSNumberChecked,
			and g.GoldenParams & 1 = 0   --SMSNumberDisabled,
			and g.GoldenParams & 32 = 32 --invito eventi enabled
 ) d











GO
