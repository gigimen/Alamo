SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [Techs].[vw_AllRichieste]
WITH SCHEMABINDING
as
SELECT 
	r.RichiestaID, 
	rt.RichiestaTypeID,
	rt.RichiestaTypeDescription, 
	GeneralPurpose.fn_UTCToLocal(1,r.InsertTimeStampUTC) as [OraRichiesta], 
	r.RichiedenteID ,
	ri.NomeReparto as [Richiedente], 
	r.Nota, 
	Techs.Priorita.PrioritDescr as [Priorita], 
	r.PerQuando,
	case
	when r.RichiestaTypeID = 1 then GeneralPurpose.fn_UTCToLocal(1,mf.InsertTimeStampUTC)
	when r.RichiestaTypeID = 3 then GeneralPurpose.fn_UTCToLocal(1,iisf.InterventoTimeStampUTC)
	when r.RichiestaTypeID = 4 then GeneralPurpose.fn_UTCToLocal(1,iist.InterventoTimeStampUTC)
	ELSE NULL
	end as [OraIncarico],
	case
	when r.RichiestaTypeID = 1 then umf.LastName
	when r.RichiestaTypeID = 3 then uisf.LastName
	when r.RichiestaTypeID = 4 then uist.LastName
	ELSE null
	end	as [Incaricato],
	iisf.StatoTypeID AS StatoInterventoFacility,
	mf.StatoOrdineID AS StatoMaterialeFacility,
	iist.StatoTypeID AS StatoInterventoTecnico,
	case
	when r.RichiestaTypeID = 1 then ISNULL(smf.StatoOrdineDescription,'in accettazione')
	when r.RichiestaTypeID = 3 then ISNULL(sisf.StatoTypeDescription,'in accettazione')
	when r.RichiestaTypeID = 4 then ISNULL(sist.StatoTypeDescription,'in accettazione')
    ELSE NULL 
	end	as Stato

FROM Techs.Richieste r
INNER JOIN techs.RichiestaTypes rt ON rt.RichiestaTypeID = r.RichiestaTypeID
INNER JOIN Techs.Richiedenti ri ON  ri.RichiedenteID = r.RichiedenteID 
INNER JOIN Techs.Priorita ON r.PrioritaID = Techs.Priorita.PrioritaID 
--intervento facility
left outer join [Techs].[InterventiServiziFacility] isf on isf.InterventoID = r.InterventoID
left outer join [Techs].[Interventi] iisf on isf.InterventoID = iisf.InterventoID
left outer JOIN CasinoLayout.Users uisf ON iisf.OwnerUserID = uisf.UserID
LEFT OUTER JOIN techs.StatoTypes sisf ON sisf.StatoTypeID = iisf.StatoTypeID
--materiale facility
left outer join Techs.MaterialeFacility mf on mf.MaterialeFacilityID = r.MaterialeFacilityID
left outer JOIN CasinoLayout.Users umf ON mf.OwnerUserID = umf.UserID
LEFT outer join Techs.StatiOrdine smf on smf.StatoOrdineID = mf.StatoOrdineID
--intervento tecnico
left outer join [Techs].[InterventiServizi] ist on ist.InterventoID = r.InterventoID
left outer join [Techs].[Interventi] iist on ist.InterventoID = iist.InterventoID
left outer JOIN CasinoLayout.Users uist ON iist.OwnerUserID = uist.UserID
LEFT outer join Techs.StatoTypes sist on sist.StatoTypeID = iist.StatoTypeID


GO
