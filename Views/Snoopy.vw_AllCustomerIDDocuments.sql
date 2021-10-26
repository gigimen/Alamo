SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Snoopy].[vw_AllCustomerIDDocuments]
WITH SCHEMABINDING
AS
SELECT  cust.CustomerID,
	cust.FirstName,
	cust.LastName,
	cust.Sesso,
	cust.BirthDate,
	cust.InsertDate AS CustInsertDate,
	cust.IdentificationID,
	sec.SectorName,
	ids.GamingDate AS IdentificationGamingDate,
	doc.Address,
	domi.FDescription AS Domicilio,
	doc.DomicilioID AS DomicilioID,
	cust.NRTelefono,
	doc.IDDocumentID 	,
	doc.DocNumber 		,
	doc.ExpirationDate 	,
	citi.FDescription AS Citizenship 	,
	doc.CitizenshipID AS CitizenshipID,
	doc.IDDocTypeID,
	Snoopy.tbl_IDDocTypes.NotForIdentification,
	Snoopy.tbl_IDDocTypes.FDescription AS DocType,
	--iddoc.IDDocumentID as IdUsedForIdentific,
	CASE 
		WHEN ids.IDDocumentID = doc.IDDocumentID THEN 1
		ELSE 0
	END AS UsedForIdentification,
	GeneralPurpose.fn_UTCToLocal(1,doc.InsertTimeStampUTC) AS InsertTimeStampLoc,
	doc.InsertGamingDate,
	si.FName AS InsertSiteName,
	ui.Lastname AS InsertUser,
	ai.FName AS InsertAppName,
	CASE 
		WHEN doc.ExpirationDate < GETUTCDATE() - 1 THEN 1
		ELSE NULL
	END AS DocExpired
,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL THEN NULL
		ELSE 1
	END IsGoldenClubMember,
	g.GoldenClubCardID,
	g.EMailAddress,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) AS StartUseMobileTimeStamp,
	g.SMSNumber,
	g.IDDocumentID AS GoldenIDDocumentID,
	CASE 
		WHEN g.IDDocumentID = doc.IDDocumentID THEN 1
		ELSE 0
	END AS UsedForGoldenClub,
	ch.ColloquioGamingDate,
	ch.FormIVtimeLoc,
	gp.[Scadenza] AS ScadenzaGreenPass
	
FROM    Snoopy.tbl_IDDocuments doc
	INNER JOIN  Snoopy.tbl_IDDocTypes ON Snoopy.tbl_IDDocTypes.IDDocTypeID = doc.IDDocTypeID 
	INNER JOIN  Snoopy.tbl_Customers cust ON cust.CustomerID = doc.CustomerID 
	INNER JOIN  Snoopy.tbl_Nazioni citi ON doc.CitizenshipID = citi.NazioneID 
	INNER JOIN  Snoopy.tbl_Nazioni domi ON doc.DomicilioID   = domi.NazioneID 
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses ua ON ua.UserAccessID = doc.UserAccessID
	LEFT OUTER JOIN CasinoLayout.Sectors	sec	ON sec.SectorID = cust.SectorID
	LEFT OUTER JOIN CasinoLayout.Users	ui	ON ui.UserID = ua.UserID
	LEFT OUTER JOIN CasinoLayout.Sites	si	ON si.SiteID = ua.SiteID
	LEFT OUTER JOIN [GeneralPurpose].[Applications]	ai	ON ai.ApplicationID = ua.ApplicationID
	LEFT OUTER JOIN Snoopy.tbl_Identifications ids ON ids.IdentificationID = cust.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch ON ch.ChiarimentoID = ids.ChiarimentoID
	LEFT OUTER JOIN GoldenClub.tbl_Members g ON g.CustomerID = cust.CustomerID
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = cust.CustomerID 	
WHERE cust.CustCancelID IS NULL











GO
