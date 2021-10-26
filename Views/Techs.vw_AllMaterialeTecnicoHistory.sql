SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Techs].[vw_AllMaterialeTecnicoHistory]
WITH SCHEMABINDING
AS
SELECT    
i.MaterialeTecnicoID, 
i.Descrizione,
--i.GamingDate,
i.OwnerUserID,
GeneralPurpose.fn_UTCToLocal(1, i.InsertTimeStampUTC) AS InterventoTimeStampLoc,
h.InsertUserAccessID,
h.HistDescr,
i.StatoOrdineID,
st.StatoOrdineDescription,
i.RichiedenteID,
r.NomeReparto,
u.LastName as UserName,
ow.LastName AS OwnerName,
GeneralPurpose.fn_UTCToLocal(1, h.InsertTimeStampUTC) AS InsertTimeStampLoc
FROM Techs.MaterialeTecnicoHistory h 
INNER JOIN Techs.MaterialeTecnico AS i ON h.MaterialeTecnicoID = i.MaterialeTecnicoID
INNER JOIN FloorActivity.tbl_UserAccesses ua on ua.UserAccessID = h.InsertUserAccessID
INNER JOIN CasinoLayout.Users u on u.UserID = ua.UserID
INNER JOIN CasinoLayout.Users ow on ow.UserID = i.OwnerUserID
INNER JOIN Techs.StatiOrdine st ON st.StatoOrdineID = i.StatoOrdineID 
LEFT OUTER JOIN Techs.Richiedenti r ON r.RichiedenteID = i.RichiedenteID
GO
