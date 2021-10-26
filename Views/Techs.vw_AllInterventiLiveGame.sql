SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Techs].[vw_AllInterventiLiveGame]
WITH SCHEMABINDING
AS
SELECT    
i.InterventoID, 
i.Descrizione,
--i.GamingDate,
GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS InterventoTimeStampLoc,
i.StatoTypeID,
i.Tecnico2UserID,
t2.LastName AS Tecnico2UserName,
st.StatoTypeDescription as StatoType,
h2.TotModifiche,
--u.LastName as UserName,
isl.ProblemaLiveGameSubTypeID, 
p.ProblemaLiveGameSubTypeDescription,
p.ProblemaLiveGameTypeID ,
p2.ProblemaLiveGameTypeDescription,
isl.SoluzioneLiveGameTypeID,
Techs.SoluzioneLiveGameTypes.SoluzioneLiveGameTypeDescription,
i.RichiedenteID,
r.NomeReparto as Richiedente,
isl.ContaOre,
isl.MachineLiveGameID,
mac.MachineLiveGameDescription,
isl.TableLiveGameID,
tab.TableLiveGameDescription,
i.OwnerUserID,
CreatorU.LastName AS OwnerName,
hu.LastName as LastUser,
GeneralPurpose.fn_UTCToLocal(1, h.InsertTimeStampUTC) AS LastTimeStampLoc,
ric.RichiestaID,
ric.PerQuando,
GeneralPurpose.fn_UTCToLocal(1,ric.InsertTimeStampUTC) AS OraRichiesta,
Techs.Priorita.PrioritDescr as [Priorita],
rt.RichiestaTypeID,
rt.RichiestaTypeDescription

FROM Techs.InterventiLiveGame AS isl 
INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
INNER JOIN Techs.ProblemaLiveGameSubTypes p ON isl.ProblemaLiveGameSubTypeID = p.ProblemaLiveGameSubTypeID 
INNER JOIN Techs.ProblemaLiveGameTypes p2 ON p2.ProblemaLiveGameTypeID = p.ProblemaLiveGameTypeID 
INNER JOIN Techs.SoluzioneLiveGameTypes ON isl.SoluzioneLiveGameTypeID = Techs.SoluzioneLiveGameTypes.SoluzioneLiveGameTypeID
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
left outer join Techs.TableLiveGame tab on tab.TableLiveGameID = isl.TableLiveGameID
left outer join Techs.MachineLiveGame mac on mac.MachineLiveGameID = isl.MachineLiveGameID
LEFT OUTER JOIN techs.Richieste ric ON ric.InterventoID = isl.InterventoID
LEFT OUTER JOIN Techs.Priorita ON Techs.Priorita.PrioritaID = ric.PrioritaID
LEFT OUTER JOIN techs.RichiestaTypes rt ON rt.RichiestaTypeID = ric.RichiestaTypeID

GO
