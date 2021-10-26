SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  VIEW [Snoopy].[vw_PersoneIdentificate]
--WITH SCHEMABINDING
AS
SELECT  i.IdentificationID,
	c.CustomerID,
	i.IdCauseID,
	CASE WHEN i.IDCauseID = 13 THEN i.Note ELSE r.Nota END AS Note, 
	i.CategoriaRischio,
	ic.FDescription AS Causale,
	ic.GoldenClubMemberTypeID AS GoldenClubMemberTypeID,
	c.FirstName, 
	c.LastName, 
	c.BirthDate,
	c.InsertDate AS CustInsertDate,
	c.Sesso,
	c.NrTelefono,
	sec.SectorName,
	doc.Address,
	domi.NazioneID AS DomicilioID,
	domi.FDescription AS Domicilio,
	i.InsertTimeStampUTC,
	GeneralPurpose.fn_UTCToLocal(1,i.InsertTimeStampUTC) AS IdentificationTime,
	i.Gamingdate AS IdentificationGamingDate,
--	[GeneralPurpose].[fn_UTCToLocal](1,ch.ChiarimentoTime) as ChiarimentoTime,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVtimeLoc,
	ch.AttivitaProf,
	ch.ProvenienzaPatr,
	ch.AltreInfo,
	Snoopy.tbl_IDDocTypes.FDescription AS DocType,
	doc.DocNumber,
	Snoopy.tbl_IDDocTypes.FDescription + ' ' +	doc.DocNumber AS DocInfo,
	doc.IDDocumentID,
	doc.ExpirationDate,
	citi.NazioneID AS CitizenshipID,
	citi.FDescription AS Citizenship,
	i.RegID,
	r.StockID,
	r.Tag,
	r.GamingDate AS RegistrationGamingDate,
	r.Transazione,
	r.Causeid AS RegCauseID,
	r.Importo,
	USOWN.LastName + ' ' + USOWN.Firstname AS Responsible,
	OWNSites.FName AS SiteName,
	GeneralPurpose.fn_UTCToLocal(1,i.SMCheckTimeStampUTC) AS SMCheckTime,
	UCHECK.LastName + ' ' + UCHECK.Firstname AS CheckedBy,
	gp.[Scadenza] AS ScadenzaGreenPass
FROM    Snoopy.tbl_Customers c
	INNER JOIN Snoopy.tbl_Identifications i	ON i.IdentificationID = c.IdentificationID	
	INNER JOIN Snoopy.tbl_IDCauses ic	ON ic.IdCauseID = i.IdCauseID	
	INNER JOIN FloorActivity.tbl_UserAccesses UAOWN	ON UAOWN.UserAccessID = i.IdentificationUserAccessID	
	INNER JOIN CasinoLayout.Users USOWN	ON USOWN.UserID = UAOWN.UserID 	
	INNER JOIN CasinoLayout.Sites OWNSites	ON OWNSites.SiteID = UAOWN.SiteID 	
	LEFT OUTER JOIN CasinoLayout.Sectors sec	ON sec.SectorID = c.SectorID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch	ON ch.ChiarimentoID = i.ChiarimentoID
	LEFT OUTER JOIN Snoopy.tbl_IDDocuments doc ON doc.IDDocumentID = i.IDDocumentID
	LEFT OUTER JOIN Snoopy.tbl_IDDocTypes ON Snoopy.tbl_IDDocTypes.IDDocTypeID = doc.IDDocTypeID 
	LEFT OUTER JOIN  Snoopy.tbl_Nazioni citi ON doc.CitizenshipID = citi.NazioneID 
	LEFT OUTER JOIN  Snoopy.tbl_Nazioni domi ON doc.DomicilioID   = domi.NazioneID 
	LEFT OUTER JOIN Snoopy.vw_AllRegistrations r	ON i.RegID = r.RegID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses UACHECK	ON UACHECK.UserAccessID = i.SMCheckUserAccessID
	LEFT OUTER JOIN CasinoLayout.Users UCHECK	ON UCHECK.UserID = UACHECK.UserID 
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = c.CustomerID 
WHERE   (c.CustCancelID IS NULL)






GO
