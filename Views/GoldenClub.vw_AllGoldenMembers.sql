SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [GoldenClub].[vw_AllGoldenMembers]
WITH SCHEMABINDING
AS
SELECT  c.CustomerID,
	c.LastName, 
	c.FirstName, 
	c.Sesso,
	c.BirthDate, 
	c.InsertDate AS CustInsertDate,
	g.InsertTimeStampUTC,
	g.CancelID AS GCCancelID,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) AS StartUseMobileTimeStamp,
	g.SMSNumber,
	g.GoldenParams,
	g.Categoria,
	CASE WHEN g.GoldenParams & 2 = 2 THEN 1	ELSE 0	END AS SMSNumberChecked,
	CASE WHEN g.GoldenParams & 1 = 1 THEN 1	ELSE 0	END AS SMSNumberDisabled,
	g.MemberTypeID,
	GeneralPurpose.fn_UTCToLocal(1,g.SMSNumberCheckedTimestampUTC) AS SMSNumberCheckedTimeStampLoc,
	GeneralPurpose.fn_UTCToLocal(1,g.LinkTimeStampUTC) AS ConsegnaCarta,
	gc.GoldenClubCardID, 
	gc.CardStatusID,
	gcs.FDescription 	AS CardStatus,
	gc.CustomerID 		AS GCCustomerid,
	g.EMailAddress,
	d.ExpirationDate 	AS GCExpirationDate,
	d.IDDocumentID 		AS GCIDDocumentID,
	citi.FDescription 	AS Citizenship 	,
	citi.NazioneID 		AS CitizenshipID,
--	gc2.GoldenClubCardID 	AS PersonalCardID, 
--	gc2.CardStatusID 	AS PersonalCardStatusID,
--	gcs2.FDescription 	AS PersonalCardStatus,
	c.NrTelefono,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVTimeLoc,
	c.IdentificationID,
	i.GamingDate		AS IdentificationGamingDate,
	CASE 
		WHEN g.IDDocumentID IS NOT NULL AND 
	 (d.ExpirationDate < GeneralPurpose.fn_GetGamingLocalDate2(
		GETUTCDATE(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GETUTCDATE(),GETDATE()),
		7 --Cassa Centrale StockTypeID 
		)
		)
		THEN 1
		ELSE 0
	END AS IsDocExpired,
	dt.FDescription + ' ' + d.DocNumber AS DocInfo,
	gc.CardTypeID,
	sec.SectorName,
	g.TotMoneyMove,
	g.RegistrationCount,
	GeneralPurpose.fn_UTCToLocal(1,ca.CancelDate) AS CancelDate,
	s.FName AS fromPC
FROM   GoldenClub.tbl_Members g
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = g.CustomerID
	LEFT OUTER JOIN GoldenClub.tbl_Cards gc ON g.GoldenClubCardID = gc.GoldenClubCardID 
	LEFT OUTER JOIN GoldenClub.tbl_CardStatus gcs ON gc.CardStatusID = gcs.CardStatusID
	LEFT OUTER JOIN Snoopy.tbl_Identifications i ON i.IdentificationID = c.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_IDDocuments d ON d.IDDocumentID = g.IDDocumentID
	LEFT OUTER JOIN Snoopy.tbl_Nazioni na ON d.CitizenshipID = na.NazioneID
	LEFT OUTER JOIN Snoopy.tbl_IDDocTypes dt ON dt.IDDocTypeID = d.IDDocTypeID
	LEFT OUTER JOIN Snoopy.tbl_Nazioni citi ON d.CitizenshipID = citi.NazioneID 
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch ON ch.ChiarimentoID = i.ChiarimentoID
--	LEFT OUTER JOIN GoldenClub.Cards gc2 ON g.CustomerID = gc2.CustomerID AND gc2.CancelID IS NULL
--	LEFT OUTER JOIN GoldenClub.CardStatus gcs2 ON gc2.CardStatusID = gcs2.CardStatusID
	LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = g.SectorID
	LEFT OUTER JOIN FloorActivity.tbl_Cancellations ca ON ca.CancelID = g.CancelID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses ua ON ua.UserAccessID = ca.UserAccessID
	LEFT OUTER JOIN CasinoLayout.Sites s ON s.SiteID = ua.SiteID

WHERE c.CustCancelID IS NULL AND g.MemberTypeID = 1 --only golden
GO
