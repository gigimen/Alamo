SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Techs].[vw_AllInterventiSlotDRGT]
AS


SELECT    
i.InterventoID, 
i.Descrizione,
--i.GamingDate,
i.StatoTypeID,
i.Tecnico2UserID,
tec2.LastName AS Tecnico2UserName,
st.StatoTypeDescription AS StatoType,
h2.TotModifiche,
i.RichiedenteID,
r.NomeReparto AS Richiedente,
GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS InterventoTimeStampLoc,
isl.ProblemaSlotSubTypeID, 
p.ProblemaSlotSubTypeDescription,
p.ProblemaSlotTypeID, 
p2.ProblemaSlotTypeDescription,
isl.SoluzioneSlotTypeID,
Techs.SoluzioneSlotTypes.SoluzioneSlotTypeDescription,
rap.InterventoID AS		HasRapportoTecnico,
rap.Problema,
rap.Soluzione,
CASE WHEN slo.InventoryNr IS NOT NULL THEN 1 ELSE 0 END AS IsGrouped,
ISNULL(sn.SlotCount,slo.SlotCount) AS SlotCount,
ISNULL(sn.SlotNumbers,slo.SlotNumbers) AS SlotNumbers,
ISNULL(sn.InventoryNr,slo.InventoryNr) AS InventoryNr,
ISNULL(sn.NumRAMClearDefined,0) AS NumRAMClearDefined,
ISNULL(sn.NumStatoContatoriDefined,0) AS NumStatoContatoriDefined,
rimb.InterventoID AS HasRimborso,
i.OwnerUserID,
CreatorU.LastName AS OwnerName,
hu.LastName AS LastUser,
GeneralPurpose.fn_UTCToLocal(1, h.InsertTimeStampUTC) AS LastTimeStampLoc,
ric.RichiestaID,
ric.PerQuando,
GeneralPurpose.fn_UTCToLocal(1,ric.InsertTimeStampUTC) AS OraRichiesta,
Techs.Priorita.PrioritDescr AS [Priorita],
rt.RichiestaTypeID,
rt.RichiestaTypeDescription

FROM Techs.InterventiSlot AS isl 
INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
INNER JOIN CasinoLayout.Users CreatorU ON CreatorU.UserID = i.OwnerUserID
INNER JOIN Techs.ProblemaSlotSubTypes p ON isl.ProblemaSlotSubTypeID = p.ProblemaSlotSubTypeID 
INNER JOIN Techs.ProblemaSlotTypes p2 ON p2.ProblemaSlotTypeID = p.ProblemaSlotTypeID 
INNER JOIN Techs.SoluzioneSlotTypes ON isl.SoluzioneSlotTypeID = Techs.SoluzioneSlotTypes.SoluzioneSlotTypeID
INNER JOIN Techs.StatoTypes st ON i.StatoTypeID = st.StatoTypeID 
INNER JOIN Techs.Richiedenti r ON r.RichiedenteID = i.RichiedenteID
INNER JOIN 
(
	SELECT COUNT(*) AS TotModifiche,
	MAX(InterventoHistoryID) AS LastInterventoHistoryID,
	InterventoID 
	FROM Techs.InterventiHistory GROUP BY InterventoID
) h2 ON h2.InterventoID = i.InterventoID
INNER JOIN Techs.InterventiHistory h ON h.InterventoHistoryID = h2.LastInterventoHistoryID
INNER JOIN FloorActivity.tbl_UserAccesses hua ON hua.UserAccessID = h.[InsertUserAccessID]
INNER JOIN CasinoLayout.Users hu ON hu.UserID = hua.[UserID]
LEFT OUTER JOIN 
(
	SELECT 
		InterventoID,
		COUNT(RAMClearID) AS NumRAMClearDefined,
		COUNT(StatoContatoriID) AS NumStatoContatoriDefined,
		GeneralPurpose.GroupConcat(LTRIM(InventoryNr)) AS InventoryNr,
		GeneralPurpose.GroupConcat(LTRIM(SlotNr)) AS SlotNumbers,
		COUNT(*) AS SlotCount
	FROM Techs.vw_AllInterventiSlot_SlotsDRGT
	GROUP BY InterventoID
) sn ON sn.InterventoID = isl.InterventoID
LEFT OUTER JOIN Techs.RapportiTecnici rap ON rap.InterventoID = isl.InterventoID
LEFT OUTER JOIN Techs.Rimborsi rimb ON rimb.InterventoID = rap.InterventoID
LEFT OUTER JOIN CasinoLayout.Users tec2 ON tec2.UserID = i.Tecnico2UserID
LEFT OUTER JOIN 
( 
SELECT 
		InterventoID,
		sg.SlotGroupName AS InventoryNr,
		sg.LocList AS SlotNumbers,
		(LEN(sg.LocList)) - LEN(REPLACE(sg.LocList,',',''))  + 1 AS SlotCount
FROM Techs.InterventiSlot_Slots i
INNER JOIN techs.SlotGroups sg ON i.COD_MACHIN = sg.SlotGroupName

 ) slo ON slo.InterventoID = isl.InterventoID
 LEFT OUTER JOIN techs.Richieste ric ON ric.InterventoID = isl.InterventoID
LEFT OUTER JOIN Techs.Priorita ON Techs.Priorita.PrioritaID = ric.PrioritaID
LEFT OUTER JOIN techs.RichiestaTypes rt ON rt.RichiestaTypeID = ric.RichiestaTypeID











GO
