SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE   VIEW [Snoopy].[vw_AllCustomers]
WITH SCHEMABINDING
AS
SELECT  
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.CustomerID,
	c.BirthDate,
	c.NrTelefono,
	c.IdentificationID,
	c.InsertDate AS CustInsertDate,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVTimeLoc,
	--[GeneralPurpose].[fn_UTCToLocal2](1,i.IdentificationDate) as IdentificationDate,
	i.GamingDate AS IdentificationGamingDate,
	--[GeneralPurpose].[fn_UTCToLocal2](1,ch.ChiarimentoTime) as ChiarimentoTime,
	i.RegID,
	CASE 
		WHEN g.CustomerID IS NULL /*or g.CancelID is not null */ THEN NULL
		ELSE 1
	END IsGoldenClubMember,
	g.GoldenClubCardID,
	gc.CardTypeID,
	CASE WHEN g.GoldenParams & 2 = 2 THEN 1	ELSE 0	END AS SMSNumberChecked,
	CASE WHEN g.GoldenParams & 1 = 0 THEN 1	ELSE 0	END AS SMSNumberDisabled,
	g.MemberTypeID,
	g.GoldenParams,
	ca.CancelDateLoc AS CancelDate,
	g.EMailAddress,
	--litte bug to be fixed 
	GeneralPurpose.fn_UTCToLocal(1,g.LinkTimeStampUTC) AS ConsegnaCarta,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) AS StartUseMobileTimeStamp,
	g.SMSNumber,
	g.IDDocumentID 		AS GCIDDocumentID,
	na.FDescription		AS Citizenship,
	d.ExpirationDate 	AS GCExpirationDate,
	CASE 
		WHEN g.IDDocumentID IS NOT NULL AND d.ExpirationDate <= GETDATE() - 1 THEN 1
		ELSE 0
	END 			AS IsDocExpired,
	dt.FDescription + ' ' + d.DocNumber AS DocInfo,
	--gc2.GoldenClubCardID 	AS PersonalCardID,
	--gc2.CardStatusID 	AS PersonalCardStatusID,
	--gcs2.FDescription 	AS PersonalCardStatus,
	c.SectorID,
	sec.SectorName,
	gp.Scadenza				AS ScadenzaGreenPass,
	gp.Scaduto				AS GreenPassScaduto
--	cor.CustomerID		AS HasCornerCard 
FROM    Snoopy.tbl_Customers c
LEFT OUTER JOIN Snoopy.tbl_Identifications i ON i.IdentificationID = c.IdentificationID
LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch ON ch.ChiarimentoID = i.ChiarimentoID
LEFT OUTER JOIN GoldenClub.tbl_Members g ON c.CustomerID = g.CustomerID
LEFT OUTER JOIN Snoopy.tbl_IDDocuments d ON d.IDDocumentID = g.IDDocumentID
LEFT OUTER JOIN Snoopy.tbl_Nazioni na ON d.CitizenshipID = na.NazioneID
LEFT OUTER JOIN Snoopy.tbl_IDDocTypes dt ON dt.IDDocTypeID = d.IDDocTypeID
LEFT OUTER JOIN GoldenClub.tbl_Cards gc ON g.GoldenClubCardID = gc.GoldenClubCardID
LEFT OUTER JOIN GoldenClub.tbl_CardStatus gcs ON gc.CardStatusID = gcs.CardStatusID
--LEFT OUTER JOIN GoldenClub.Cards gc2 ON g.CustomerID = gc2.CustomerID AND gc2.CancelID IS NULL
--LEFT OUTER JOIN GoldenClub.CardStatus gcs2 ON gc2.CardStatusID = gcs2.CardStatusID
LEFT OUTER JOIN FloorActivity.tbl_Cancellations ca ON ca.CancelID = g.CancelID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
LEFT OUTER JOIN Snoopy.tbl_GreenPass gp ON gp.CustomerID = c.CustomerID
--LEFT OUTER JOIN Snoopy.CornerCards cor ON cor.CustomerID = c.CustomerID
WHERE c.CustCancelID IS NULL
GO
