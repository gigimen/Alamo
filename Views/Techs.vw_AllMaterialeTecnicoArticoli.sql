SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Techs].[vw_AllMaterialeTecnicoArticoli]
WITH SCHEMABINDING
AS
SELECT    
o.MaterialeTecnicoID,
o.Descrizione,
--o.GamingDate,
o.StatoOrdineID,
so.StatoOrdineDescription,
GeneralPurpose.fn_UTCToLocal(1, o.InsertTimeStampUTC) AS InsertTimeStampLoc,
o.RichiedenteID,
r.NomeReparto as Richiedente,
fo.FornitoreID,
fo.FornitoreDescription,
or_ar.DescrizioneArticolo,
or_ar.NumPezzi,
o.OwnerUserID,
CreatorU.LastName AS OwnerName
FROM Techs.MaterialeTecnico_Articoli or_ar 
inner join Techs.MaterialeTecnico o on or_ar.MaterialeTecnicoID = o.MaterialeTecnicoID
inner join Techs.Fornitori fo on fo.FornitoreID = or_ar.FornitoreID
INNER JOIN Techs.Richiedenti r ON r.RichiedenteID = o.RichiedenteID
inner join Techs.StatiOrdine so on so.StatoOrdineID = o.StatoOrdineID
left outer join CasinoLayout.Users CreatorU ON CreatorU.UserID = o.OwnerUserID

GO
