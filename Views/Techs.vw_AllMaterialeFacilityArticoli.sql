SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Techs].[vw_AllMaterialeFacilityArticoli]
WITH SCHEMABINDING
AS
SELECT    
fa.MaterialeFacilityID,
fa.Descrizione,
--o.GamingDate,
fa.StatoOrdineID,
so.StatoOrdineDescription,
GeneralPurpose.fn_UTCToLocal(1, fa.InsertTimeStampUTC) AS InsertTimeStampLoc,
fa.RichiedenteID,
r.NomeReparto as Richiedente,
fo.FornitoreID,
fo.FornitoreDescription,
fa_ar.DescrizioneArticolo,
fa_ar.NumPezzi,
fa.OwnerUserID,
CreatorU.LastName AS OwnerName
FROM Techs.MaterialeFacility_Articoli fa_ar 
inner join Techs.MaterialeFacility fa on fa_ar.MaterialeFacilityID = fa.MaterialeFacilityID
inner join Techs.Fornitori fo on fo.FornitoreID = fa_ar.FornitoreID
INNER JOIN Techs.Richiedenti r ON r.RichiedenteID = fa.RichiedenteID
inner join Techs.StatiOrdine so on so.StatoOrdineID = fa.StatoOrdineID
left outer join CasinoLayout.Users CreatorU ON CreatorU.UserID = fa.OwnerUserID

GO
