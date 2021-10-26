SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Techs].[vw_AllRAMClear]
AS
SELECT	i.InterventoID
	  --,i.GamingDate
      ,GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS TimeStampLoc 
	  ,u.LastName AS UserName
	  ,ram.[RAMClearID]
      ,ram.[VisoreUserID]
      ,v.LastName AS Visore
      ,ram.[TIMPrima]
      ,ram.[TIMDopo]
      ,ram.[TISPrima]
      ,ram.[TISDopo]
      ,ram.[GMPrima]
      ,ram.[GMDopo]
      ,ram.[TOMPrima]
      ,ram.[TOMDopo]
      ,ram.[TOSPrima]
      ,ram.[TOSDopo]
      ,ram.EseguitoGiochiTest
      ,ram.EseguitoRAMClear
	  ,CASE 
		WHEN gal.ContatoriElettronici = 'Crediti' THEN ((ram.[TISDopo] - ram.[TISPrima]) - (ram.[TOSDopo] - ram.[TOSPrima]) ) * gal.DenoCents / 100
		ELSE CAST(((ram.[TISDopo] - ram.[TISPrima]) - (ram.[TOSDopo] - ram.[TOSPrima]) ) AS FLOAT) /100.0 
		END AS BSEElettronico
	  ,gal.IpAddr 
	  ,gal.SlotNr 
	  ,gal.InventoryNr
	  ,gal.DAT_DDEF
	  ,gal.MODEL
      ,gal.Manufacturer			
      ,gal.MINBET	
      ,gal.MAXBET	
	  ,gal.PCT_REDIST	
	  ,gal.DenoCents
      ,gal.ContatoriElettronici	
      ,gal.NUM_SERIE AS  SerialNumber

FROM Techs.RAMClear ram 
INNER JOIN 
(
	SELECT 
	gal.RAMClearID,
	gal.InterventoID,
	gal.SlotNr,
	gal.IpAddr,
	gal.InventoryNr
	  ,gal.DAT_DDEF
	  ,gal.MODEL
      ,gal.Manufacturer	
      ,gal.DenoCents			
      ,gal.MINBET	
      ,gal.MAXBET		
	  ,gal.PCT_REDIST	
      ,gal.ContatoriElettronici	
      ,gal.NUM_SERIE
	FROM Techs.vw_AllInterventiSlot_SlotsDRGT gal
	WHERE gal.RAMClearID IS NOT NULL
) gal ON gal.RAMCLearID = ram.RAMClearID
INNER JOIN Techs.RapportiTecnici rap ON rap.InterventoID = gal.InterventoID
INNER JOIN Techs.InterventiSlot AS isl ON rap.InterventoID = isl.InterventoID
INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
INNER JOIN CasinoLayout.Users u ON u.UserID = i.OwnerUserID
INNER JOIN CasinoLayout.Users AS v ON v.UserID = ram.[VisoreUserID]
--inner join Techs.vw_allSlotDefinitions gal ON l.COD_MACHIN = gal.smdbid and gal.dat_ddef = l.dat_ddef



















GO
