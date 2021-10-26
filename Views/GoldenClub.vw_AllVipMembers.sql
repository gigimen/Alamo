SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [GoldenClub].[vw_AllVipMembers]
WITH SCHEMABINDING
AS
SELECT  TOP 100 PERCENT
	c.CustomerID,
	c.LastName, 
	c.FirstName, 
	c.BirthDate, 
	g.TotMoneyMove,
	g.RegistrationCount,
	sec.SectorName,
--	g.SMSNumber,
--	g.SMSNumberChecked,
--	[GeneralPurpose].[fn_UTCToLocal](1,g.SMSNumberCheckedTimestampUTC) as SMSNumberCheckedTimeStampLoc,
	GeneralPurpose.fn_UTCToLocal(1,g.LinkTimeStampUTC) AS ConsegnaCarta,
	gc.GoldenClubCardID, 
	gc.CardStatusID,
	gcs.FDescription 	AS CardStatus,
--	gc.CustomerID as gccustomerid,
	g.EMailAddress,
	d.ExpirationDate,
	d.IDDocumentID,
	dt.FDescription AS DocType,
	d.DocNumber,	
	citi.NazioneID AS CitizenshipID,
	citi.FDescription AS Citizenship,
	c.NrTelefono,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVTimeLoc,
	c.IdentificationID,
	i.GamingDate AS IdentificationGamingDate,
	CASE 
		WHEN g.IDDocumentID IS NULL OR d.ExpirationDate <= GETDATE() - 1 THEN 1
		ELSE 0
	END AS IsDocExpired,
	gc.CardTypeID,
	CASE WHEN gc.CardTypeID = 1 THEN 1 ELSE 0 END	AS IsTemporaryCard
FROM   GoldenClub.tbl_Members g
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = g.CustomerID
	INNER JOIN Snoopy.tbl_Identifications i ON i.IdentificationID = c.IdentificationID
	INNER JOIN Snoopy.tbl_IDDocuments d ON d.IDDocumentID = g.IDDocumentID
	INNER JOIN Snoopy.tbl_IDDocTypes dt ON dt.IDDocTypeID = d.IDDocTypeID
	INNER JOIN Snoopy.tbl_Nazioni citi ON d.CitizenshipID = citi.NazioneID 
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch ON ch.ChiarimentoID = i.ChiarimentoID
	LEFT OUTER JOIN GoldenClub.tbl_Cards gc ON g.GoldenClubCardID = gc.GoldenClubCardID 
	LEFT OUTER JOIN CasinoLayout.Sectors sec ON g.SectorID = sec.SectorID 
	LEFT OUTER JOIN GoldenClub.tbl_CardStatus gcs ON gc.CardStatusID = gcs.CardStatusID
WHERE g.CancelID IS NULL AND g.LinkTimeStampUTC IS NOT NULL
ORDER BY g.TotMoneyMove DESC
GO
