SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Techs].[vw_AllRimborsi]
AS

--corretto case

/*COM'ERA
SELECT    
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.CustomerID,
	c.BirthDate,
	c.NrTelefono,
	d.Address + ' - ' + n.FDescription AS Domicilio,
	c.IdentificationID,
	c.InsertDate AS CustInsertDate,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVTimeLoc,
	sec.SectorName,
	t.LastName AS UserName,
	--[GeneralPurpose].[fn_UTCToLocal2](1,i.IdentificationDate) as IdentificationDate,
	id.GamingDate AS IdentificationGamingDate,
	--[GeneralPurpose].[fn_UTCToLocal2](1,ch.ChiarimentoTime) as ChiarimentoTime,
	id.RegID,
	rim.InterventoID, 
	--i.GamingDate,
	[GeneralPurpose].[fn_UTCToLocal2](1, i.InterventoTimeStampUTC) AS InterventoTimeStampLoc,
	isl.ProblemaSlotSubTypeID, 
	isl.SoluzioneSlotTypeID,
	rap.Problema,
	rap.Soluzione,
	rim.InterventoID AS Rimborso,
	rim.__ImportoSfr AS ImportoSfr,
	s.StockID,
	rim.IDDocumentID,
	s.Tag,
	rim.__ShiftUserID AS ShiftUserID,
	u.LastName AS ShiftName,
	rim.TimeStampUTC,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL  THEN NULL
		ELSE g.GoldenClubCardID
	END AS GoldenClubCardID
	  ,gal.Location 
	  ,gal.SMDBID
	  ,gal.Model
      ,gal.MANUF			
      ,gal.MINBETSFR		
      ,gal.MAXBETSFR		
      ,gal.MAXWINSFR		
	  ,gal.PCT_REDIST	
	  ,gal.Denomination
	  ,gal.MeccCountType	
      ,gal.EleCountType	
      ,gal.NUM_SERIE

FROM Techs.Rimborsi rim 
INNER JOIN Techs.RapportiTecnici rap ON rap.InterventoID = rim.InterventoID
INNER JOIN Snoopy.Customers c ON rim.CustomerID=c.CustomerID
INNER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
INNER JOIN Snoopy.IDDocuments d ON rim.IDDocumentID=d.IDDocumentID
INNER JOIN Snoopy.Nazioni n ON n.NazioneID = d.DomicilioID
INNER JOIN Techs.InterventiSlot AS isl ON rap.InterventoID = isl.InterventoID
INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
INNER JOIN Techs.InterventiSlot_Slots slo ON slo.InterventoID = i.InterventoID
INNER JOIN CasinoLayout.Users t ON t.UserID = i.OwnerUserID
INNER JOIN Techs.vw_allSlotDefinitions gal ON slo.COD_MACHIN = gal.smdbid AND gal.dat_ddef = slo.dat_ddef AND gal.FloorSfr = slo.FloorSfr
LEFT OUTER JOIN CasinoLayout.Stocks s ON s.StockID = rim.__StockID
LEFT OUTER JOIN CasinoLayout.Users u ON u.UserID = rim.__ShiftUserID
LEFT OUTER JOIN Snoopy.Identifications id ON id.IdentificationID = c.IdentificationID
LEFT OUTER JOIN Snoopy.Chiarimenti ch ON ch.ChiarimentoID = id.ChiarimentoID
LEFT OUTER JOIN GoldenClub.Members g ON g.CustomerID = rim.CustomerID
*/

/*COME SARA'*/


SELECT    
	rim.InterventoID, 
	rim.TimeStampUTC,
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.CustomerID,
	c.BirthDate,
	c.NrTelefono,
	d.Address + ' - ' + n.FDescription AS Domicilio,
	c.IdentificationID,
	c.InsertDate AS CustInsertDate,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVTimeLoc,
	sec.SectorName,
	t.LastName AS UserName,
	--[GeneralPurpose].[fn_UTCToLocal2](1,i.IdentificationDate) as IdentificationDate,
	id.GamingDate AS IdentificationGamingDate,
	--[GeneralPurpose].[fn_UTCToLocal2](1,ch.ChiarimentoTime) as ChiarimentoTime,
	id.RegID,
	--i.GamingDate,
	GeneralPurpose.fn_UTCToLocal(1, i.InterventoTimeStampUTC) AS InterventoTimeStampLoc,
	isl.ProblemaSlotSubTypeID, 
	isl.SoluzioneSlotTypeID,
	rap.Problema,
	rap.Soluzione,
	st.SlotTransactionID,
	st.AmountCents,
	CAST(st.AmountCents AS FLOAT)/ 100.00  AS ImportoSfr,
	lf.StockID,
	rim.IDDocumentID,
	s.Tag,
	lf.OwnerUserID AS ShiftUserID,
	lf.OwnerName AS ShiftName,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL  THEN NULL
		ELSE g.GoldenClubCardID
	END AS GoldenClubCardID
	  ,gal.IpAddr 
	  ,gal.InventoryNr
	  ,gal.Model
      ,gal.MANUF			
      ,gal.MINBETSFR		
      ,gal.MAXBETSFR		
	  ,gal.PCT_REDIST	
	  ,gal.Denomination
      ,gal.ELECOUNTTYPE	
      ,gal.NUM_SERIE
	  
FROM Techs.Rimborsi rim 
INNER JOIN Techs.RapportiTecnici rap ON rap.InterventoID = rim.InterventoID
INNER JOIN Snoopy.tbl_Customers c ON rim.CustomerID=c.CustomerID
INNER JOIN Snoopy.tbl_IDDocuments d ON rim.IDDocumentID=d.IDDocumentID
INNER JOIN Snoopy.tbl_Nazioni n ON n.NazioneID = d.DomicilioID
INNER JOIN Techs.InterventiSlot AS isl ON rap.InterventoID = isl.InterventoID
INNER JOIN Techs.Interventi AS i ON i.InterventoID = isl.InterventoID 
INNER JOIN [Techs].[tbl_InterventiSlot_SlotsDRGT] slo ON slo.InterventoID = i.InterventoID
INNER JOIN Techs.vw_AllSlotDefinitions gal ON slo.IpAddr = gal.IpAddr
INNER JOIN CasinoLayout.Users t ON t.UserID = i.OwnerUserID
INNER JOIN Accounting.tbl_SlotTransactions st ON st.InterventoID = rim.InterventoID
LEFT OUTER JOIN Accounting.vw_AllStockLifeCycles lf ON lf.LifeCycleID = st.LifeCycleID 
LEFT OUTER JOIN CasinoLayout.Stocks s ON s.StockID = lf.StockID
LEFT OUTER JOIN Snoopy.tbl_Identifications id ON id.IdentificationID = c.IdentificationID
LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch ON ch.ChiarimentoID = id.ChiarimentoID
LEFT OUTER JOIN GoldenClub.tbl_Members g ON g.CustomerID = rim.CustomerID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
GO
