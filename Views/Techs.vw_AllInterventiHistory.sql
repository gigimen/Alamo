SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Techs].[vw_AllInterventiHistory]
WITH SCHEMABINDING
AS
SELECT    
i.InterventoID, 
i.Descrizione,
--i.GamingDate,
i.OwnerUserID,
GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS InterventoTimeStampLoc,
h.InsertUserAccessID,
h.HistDescr,
i.StatoTypeID,
st.StatoTypeDescription,
i.RichiedenteID,
r.NomeReparto,
u.LastName as UserName,
ow.LastName AS OwnerName,
GeneralPurpose.fn_UTCToLocal(1, h.InsertTimeStampUTC) AS InsertTimeStampLoc
FROM Techs.InterventiHistory h 
INNER JOIN Techs.Interventi AS i ON h.InterventoID = i.InterventoID
INNER JOIN FloorActivity.tbl_UserAccesses ua on ua.UserAccessID = h.InsertUserAccessID
INNER JOIN CasinoLayout.Users u on u.UserID = ua.UserID
INNER JOIN CasinoLayout.Users ow on ow.UserID = i.OwnerUserID
INNER JOIN Techs.StatoTypes st ON st.StatoTypeID = i.StatoTypeID 
LEFT OUTER JOIN Techs.Richiedenti r ON r.RichiedenteID = i.RichiedenteID














GO
