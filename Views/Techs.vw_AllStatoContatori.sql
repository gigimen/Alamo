SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Techs].[vw_AllStatoContatori]
AS
SELECT	i.InterventoID
	  --,i.GamingDate
      ,GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS TimeStampLoc 
	  ,u.LastName as UserName
	  ,ram.[StatoContatoriID]
      ,ram.[VisoreUserID]
      ,v.LastName as Visore
      ,ram.[TIM]
      ,ram.[TIS]
      ,ram.[GM]
      ,ram.[TOM]
      ,ram.[TOS]
	  ,gal.IpAddr 
	  ,gal.InventoryNr
	  ,gal.MODEL
      ,gal.MANUFacturer			
      ,gal.MINBET		
      ,gal.MAXBET		
 	  ,gal.PCT_REDIST	
	  ,gal.[DenoCents]
      ,gal.ContatoriElettronici	
      ,gal.NUM_SERIE

FROM Techs.StatoContatori ram 
inner join 
(
	SELECT 
	gal.StatoContatoriID,
	gal.InterventoID,
	gal.InventoryNr
	,gal.IpAddr
	  ,gal.DAT_DDEF
	  ,gal.MODEL
      ,gal.MANUFacturer	
      ,gal.[DenoCents]			
      ,gal.MINBET		
      ,gal.MAXBET				
	  ,gal.PCT_REDIST	
      ,gal.ContatoriElettronici	
      ,gal.NUM_SERIE
	FROM Techs.vw_AllInterventiSlot_SlotsDRGT gal
	where gal.StatoContatoriID is not null
) gal on gal.StatoContatoriID = ram.StatoContatoriID
inner join Techs.RapportiTecnici rap on rap.InterventoID = gal.InterventoID
inner join Techs.InterventiSlot AS isl on rap.InterventoID = isl.InterventoID
INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
INNER JOIN CasinoLayout.Users u on u.UserID = i.OwnerUserID
inner join CasinoLayout.Users as v on v.UserID = ram.[VisoreUserID]
--inner join Techs.vw_allSlotDefinitions gal ON l.COD_MACHIN = gal.smdbid and gal.dat_ddef = l.dat_ddef





GO
