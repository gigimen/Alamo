SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Techs].[vw_AllMaterialeFacility]
WITH SCHEMABINDING
AS
SELECT    
o.MaterialeFacilityID,
o.Descrizione,
--o.GamingDate,
o.StatoOrdineID,
so.StatoOrdineDescription,
h2.TotModifiche,
GeneralPurpose.fn_UTCToLocal(1, o.InsertTimeStampUTC) AS InsertTimeStampLoc,
o.RichiedenteID,
r.NomeReparto as Richiedente,
sn.Articoli,
sn.TotPezzi,
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

FROM Techs.MaterialeFacility AS o 
inner join Techs.StatiOrdine so on so.StatoOrdineID = o.StatoOrdineID
inner join Techs.Richiedenti r ON r.RichiedenteID = o.RichiedenteID
inner join CasinoLayout.Users CreatorU ON CreatorU.UserID = o.OwnerUserID
left outer join
(
	select count(*) as TotModifiche,
	max(MaterialeFacilityHistoryID) as LastFacilityHistoryID,
	MaterialeFacilityID 
	from Techs.MaterialeFacilityHistory 
	group by MaterialeFacilityID
) h2 ON h2.MaterialeFacilityID = o.MaterialeFacilityID
left outer join Techs.MaterialeFacilityHistory h			ON h.MaterialeFacilityHistoryID = h2.LastFacilityHistoryID
LEFT outer join 
(
	select MaterialeFacilityID,
		[GeneralPurpose].GroupConcat(DescrizioneArticolo) as Articoli,
		SUM(isnull(NumPezzi,1)) as TotPezzi
	from Techs.MaterialeFacility_Articoli  
	group by MaterialeFacilityID
) sn on sn.MaterialeFacilityID = o.MaterialeFacilityID
left outer join FloorActivity.tbl_UserAccesses hua	ON hua.UserAccessID = h.[InsertUserAccessID]
left outer join CasinoLayout.Users hu			ON hu.UserID = hua.[UserID]
LEFT OUTER JOIN techs.Richieste ric ON ric.MaterialeFacilityID = o.MaterialeFacilityID
LEFT OUTER JOIN Techs.Priorita ON Techs.Priorita.PrioritaID = ric.PrioritaID
LEFT OUTER JOIN techs.RichiestaTypes rt ON rt.RichiestaTypeID = ric.RichiestaTypeID




GO
