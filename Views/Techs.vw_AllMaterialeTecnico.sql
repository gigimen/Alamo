SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Techs].[vw_AllMaterialeTecnico]
WITH SCHEMABINDING
AS
SELECT    
o.MaterialeTecnicoID,
o.Descrizione,
--o.GamingDate,
o.StatoOrdineID,
so.StatoOrdineDescription,
h2.TotModifiche,
GeneralPurpose.fn_UTCToLocal(1, o.InsertTimeStampUTC) AS InsertTimeStampLoc,
o.RichiedenteID,
r.NomeReparto as Richiedente,
Sn.Articoli,
Sn.TotPezzi,
o.OwnerUserID,
CreatorU.LastName AS OwnerName,
hu.LastName as LastUser,
GeneralPurpose.fn_UTCToLocal(1, h.InsertTimeStampUTC) AS LastTimeStampLoc,
ric.RichiestaID,
ric.PerQuando,
GeneralPurpose.fn_UTCToLocal(1,ric.InsertTimeStampUTC) AS OraRichiesta,
Techs.Priorita.PrioritDescr as [Priorita],
rt.RichiestaTypeID,
rt.RichiestaTypeDescription


FROM Techs.MaterialeTecnico AS o 
inner join Techs.StatiOrdine so on so.StatoOrdineID = o.StatoOrdineID
inner join Techs.Richiedenti r ON r.RichiedenteID = o.RichiedenteID
inner join CasinoLayout.Users CreatorU ON CreatorU.UserID = o.OwnerUserID
inner join
(
	select count(*) as TotModifiche,
	max(MaterialeTecnicoHistoryID) as LastMaterialeTecnicoHistoryID,
	MaterialeTecnicoID 
	from Techs.MaterialeTecnicoHistory 
	group by MaterialeTecnicoID
) h2 ON h2.MaterialeTecnicoID = o.MaterialeTecnicoID
inner join Techs.MaterialeTecnicoHistory h ON h.MaterialeTecnicoHistoryID = h2.LastMaterialeTecnicoHistoryID
inner join FloorActivity.tbl_UserAccesses hua ON hua.UserAccessID = h.[InsertUserAccessID]
inner join CasinoLayout.Users hu ON hu.UserID = hua.[UserID]
LEFT outer join 
(
	select or_ar.MaterialeTecnicoID,
		[GeneralPurpose].GroupConcat(or_ar.DescrizioneArticolo) as Articoli,
		SUM(isnull(or_ar.NumPezzi,1)) as TotPezzi
	from Techs.MaterialeTecnico_Articoli or_ar 
	group by or_ar.MaterialeTecnicoID
) sn on sn.MaterialeTecnicoID = o.MaterialeTecnicoID
LEFT OUTER JOIN techs.Richieste ric ON ric.MaterialeTecnicoID = o.MaterialeTecnicoID
LEFT OUTER JOIN Techs.Priorita ON Techs.Priorita.PrioritaID = ric.PrioritaID
LEFT OUTER JOIN techs.RichiestaTypes rt ON rt.RichiestaTypeID = ric.RichiestaTypeID
GO
