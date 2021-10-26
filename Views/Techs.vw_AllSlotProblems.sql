SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Techs].[vw_AllSlotProblems]
AS
SELECT 
sn.InventoryNr
,sn.IpAddr
,sn.MODEL
,sn.Manufacturer	
,sn.DenoCents			
,sn.MINBET	
,sn.MAXBET	
,sn.PCT_REDIST	
,sn.ContatoriElettronici	
,sn.NUM_SERIE
,sn.RAMClearID
,i.InterventoID, 
i.Descrizione,
--i.GamingDate,
i.StatoTypeID,
i.Tecnico2UserID,
tec2.LastName as Tecnico2UserName,
st.StatoTypeDescription as StatoType,
h2.TotModifiche,
i.RichiedenteID,
r.NomeReparto as Richiedente,
GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS InterventoTimeStampLoc,
isl.ProblemaSlotSubTypeID, 
p.ProblemaSlotSubTypeDescription,
p.ProblemaSlotTypeID, 
p2.ProblemaSlotTypeDescription,
isl.SoluzioneSlotTypeID,
Techs.SoluzioneSlotTypes.SoluzioneSlotTypeDescription,
rap.InterventoID as		HasRapportoTecnico,
rap.Problema,
rap.Soluzione,
rimb.InterventoID as HasRimborso,
i.OwnerUserID,
CreatorU.LastName AS OwnerName,
hu.LastName as LastUser,
GeneralPurpose.fn_UTCToLocal(1, h.InsertTimeStampUTC) AS LastTimeStampLoc

FROM  [Techs].[vw_AllInterventiSlot_SlotsDRGT] sn 
INNER JOIN Techs.InterventiSlot AS isl on sn.InterventoID = isl.InterventoID
INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
inner join CasinoLayout.Users CreatorU ON CreatorU.UserID = i.OwnerUserID
INNER JOIN Techs.ProblemaSlotSubTypes p ON isl.ProblemaSlotSubTypeID = p.ProblemaSlotSubTypeID 
INNER JOIN Techs.ProblemaSlotTypes p2 ON p2.ProblemaSlotTypeID = p.ProblemaSlotTypeID 
INNER JOIN Techs.SoluzioneSlotTypes ON isl.SoluzioneSlotTypeID = Techs.SoluzioneSlotTypes.SoluzioneSlotTypeID
INNER JOIN Techs.StatoTypes st ON i.StatoTypeID = st.StatoTypeID 
INNER JOIN Techs.Richiedenti r ON r.RichiedenteID = i.RichiedenteID
inner join 
(
	select count(*) as TotModifiche,
	max(InterventoHistoryID) as LastInterventoHistoryID,
	InterventoID 
	from Techs.InterventiHistory group by InterventoID
) h2 ON h2.InterventoID = i.InterventoID
INNER JOIN Techs.InterventiHistory h ON h.InterventoHistoryID = h2.LastInterventoHistoryID
inner join FloorActivity.tbl_UserAccesses hua ON hua.UserAccessID = h.[InsertUserAccessID]
inner join CasinoLayout.Users hu ON hu.UserID = hua.[UserID]
inner join 
( 
select 
		InterventoID,
		min(cod_machin) as cod_machin,
		case
			when min(cod_machin) = '1-75' then 75
			when min(cod_machin) = '76-150' then 75
			when min(cod_machin) = '151-250' then 100
			when min(cod_machin) = 'tutte' then 250
			else 0
		end as SlotCount
from Techs.InterventiSlot_Slots 
group by InterventoID
 ) slo on slo.InterventoID = isl.InterventoID
LEFT OUTER JOIN Techs.RapportiTecnici rap ON rap.InterventoID = isl.InterventoID
LEFT OUTER JOIN Techs.Rimborsi rimb ON rimb.InterventoID = rap.InterventoID
left outer join CasinoLayout.Users tec2 ON tec2.UserID = i.Tecnico2UserID











GO
