SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Techs].[vw_AllInterventiSlot_SlotsDRGT]
AS
SELECT slo.InterventoID
		,[GeneralPurpose].[fn_GetGamingDate] (i.InterventoTimeStampUTC,1,DEFAULT) AS GamingDate
		,slo.RAMClearID
		,slo.StatoContatoriID
	  ,gal.SlotNR
      ,CAST(gal.[DENOMINATION] * 100 AS INT) AS DenoCents
	  ,gal.[IpAddr]
      ,gal.[MANUF] AS Manufacturer
      ,gal.[MODEL]
      ,gal.InventoryNr
      ,gal.[DAT_DDEF]
      ,CAST(gal.[MINBETSFR] * 100 AS INT)  AS [MinBet]
      ,CAST(gal.[MAXBETSFR] * 100 AS INT)  AS [MaxBet]
--      ,gal.[MAXWINSFR]
      ,gal.[PCT_REDIST]
--      ,gal.[MECCCOUNTTYPE]
      ,gal.[ELECOUNTTYPE] AS ContatoriElettronici
      ,gal.[NUM_SERIE]
--	  ,gal.IsActive,
		,isl.ProblemaSlotSubTypeID
		,p.ProblemaSlotSubTypeDescription
		,p.ProblemaSlotTypeID
		,p2.ProblemaSlotTypeDescription

FROM [Techs].[tbl_InterventiSlot_SlotsDRGT] slo
INNER JOIN [Techs].[vw_AllSlotDefinitions] gal ON gal.IpAddr = slo.IpAddr
INNER JOIN Techs.InterventiSlot AS isl ON isl.InterventoID = slo.InterventoID
INNER JOIN Techs.Interventi AS i ON i.InterventoID = slo.InterventoID
INNER JOIN Techs.ProblemaSlotSubTypes p ON isl.ProblemaSlotSubTypeID = p.ProblemaSlotSubTypeID 
INNER JOIN Techs.ProblemaSlotTypes p2 ON p2.ProblemaSlotTypeID = p.ProblemaSlotTypeID 


















GO
