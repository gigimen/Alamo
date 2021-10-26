SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Techs].[vw_AllInterventi]
WITH SCHEMABINDING
AS
SELECT    
i.InterventoID, 
i.Descrizione,
--i.GamingDate,
GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS InterventoTimeStampLoc,
i.StatoTypeID,
st.StatoTypeDescription as StatoType,
i.Tecnico2UserID,
t2.LastName AS Tecnico2UserName,
h2.TotModifiche,
i.OwnerUserID,
CreatorU.LastName AS OwnerName,
i.RichiedenteID,
r.NomeReparto as Richiedente,
hu.UserID AS LastUserID,
hu.LastName as LastUser,
GeneralPurpose.fn_UTCToLocal(1, h.InsertTimeStampUTC) AS LastTimeStampLoc,
IsNUll(lg.Settore,isnull(slot.Settore,ISNULL(serv.Settore,'<UNKOWN>'))) as Settore,
IsNUll(slot.Problema,isnull(lg.Problema,ISNULL(serv.Problema,'<UNKOWN>'))) as Problema,
IsNUll(slot.Soluzione,isnull(lg.Soluzione,ISNULL(serv.Soluzione,'<UNKOWN>'))) as Soluzione,
ric.RichiestaID,
ric.PerQuando,
GeneralPurpose.fn_UTCToLocal(1,ric.InsertTimeStampUTC) AS OraRichiesta,
Techs.Priorita.PrioritDescr as [Priorita],
rt.RichiestaTypeID,
rt.RichiestaTypeDescription

FROM Techs.Interventi AS i 
INNER JOIN Techs.StatoTypes st ON i.StatoTypeID = st.StatoTypeID 
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
inner join CasinoLayout.Users CreatorU ON CreatorU.UserID = i.OwnerUserID
INNER JOIN Techs.Richiedenti r ON r.RichiedenteID = i.RichiedenteID
LEFT OUTER JOIN CasinoLayout.Users t2 ON t2.UserID = i.Tecnico2UserID
left outer join 
(
	select 
	'LiveGame' as Settore,
	isl.InterventoID,
	p2.ProblemaLiveGameTypeDescription + ' - ' + p.ProblemaLiveGameSubTypeDescription as Problema,
	Techs.SoluzioneLiveGameTypes.SoluzioneLiveGameTypeDescription as Soluzione
	FROM Techs.InterventiLiveGame AS isl 
	INNER JOIN Techs.ProblemaLiveGameSubTypes p ON isl.ProblemaLiveGameSubTypeID = p.ProblemaLiveGameSubTypeID 
	INNER JOIN Techs.ProblemaLiveGameTypes p2 ON p2.ProblemaLiveGameTypeID = p.ProblemaLiveGameTypeID 
	INNER JOIN Techs.SoluzioneLiveGameTypes ON isl.SoluzioneLiveGameTypeID = Techs.SoluzioneLiveGameTypes.SoluzioneLiveGameTypeID
) lg on lg.InterventoID = i.InterventoID
left outer join 
(
	select 
		'Slot' as Settore,
		isl.InterventoID,
		p2.ProblemaSlotTypeDescription + ' - ' +
		p.ProblemaSlotSubTypeDescription as Problema,	
		Techs.SoluzioneSlotTypes.SoluzioneSlotTypeDescription as Soluzione
	FROM Techs.InterventiSlot AS isl 
	INNER JOIN Techs.ProblemaSlotSubTypes p ON isl.ProblemaSlotSubTypeID = p.ProblemaSlotSubTypeID 
	INNER JOIN Techs.ProblemaSlotTypes p2 ON p2.ProblemaSlotTypeID = p.ProblemaSlotTypeID 
	INNER JOIN Techs.SoluzioneSlotTypes ON isl.SoluzioneSlotTypeID = Techs.SoluzioneSlotTypes.SoluzioneSlotTypeID
) slot on slot.InterventoID = i.InterventoID
left outer join 
(
	select 
		'Servizi' as Settore,
		isl.InterventoID, 
		CASE 
		WHEN al.AllarmeTypeDescription IS NULL THEN	sety.ServiziTypeDescription 
		ELSE sety.ServiziTypeDescription + ' - ' + al.AllarmeTypeDescription
		end AS Problema,
		i.Descrizione AS Soluzione
	FROM Techs.InterventiServizi AS isl 
	INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
	inner join Techs.ServiziTypes sety ON sety.serviziTypeID = isl.serviziTypeID
	left outer join Techs.Ditte di on di.DittaID = isl.DittaID
	left outer join Techs.AllarmeTypes al on al.AllarmeTypeID = isl.AllarmeTypeID

) serv on serv.InterventoID = i.InterventoID
LEFT OUTER JOIN techs.Richieste ric ON ric.InterventoID = i.InterventoID
LEFT OUTER JOIN Techs.Priorita ON Techs.Priorita.PrioritaID = ric.PrioritaID
LEFT OUTER JOIN techs.RichiestaTypes rt ON rt.RichiestaTypeID = ric.RichiestaTypeID

GO
