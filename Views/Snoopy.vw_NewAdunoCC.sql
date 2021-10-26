SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_NewAdunoCC]
WITH SCHEMABINDING
AS
SELECT  
	c.FirstName AS Nome, 
	c.LastName AS Cognome, 
	c.BirthDate AS DataNascita, 
	c.GamingDate , 
	dt.FDescription AS TipoDocumento,
	d.ExpirationDate,
	d.DocNumber,
	d.DomicilioID,
	domi.FDescription AS StatoDomicilio,
	d.CitizenshipID,
	citi.FDescription AS Citizenship,
	d.Address,
	GeneralPurpose.fn_UTCToLocal(1,MIN(d.InsertTimeStampUTC)) AS InsertTimeLocal
	
FROM    Accounting.vw_AllCartediCredito c
INNER JOIN Snoopy.tbl_IDDocuments d ON d.IDDocumentID = c.IDDocumentID 
INNER JOIN Snoopy.tbl_IDDocTypes dt ON dt.IDDocTypeID = d.IDDocTypeID
INNER JOIN  Snoopy.tbl_Nazioni citi ON d.CitizenshipID = citi.NazioneID 
INNER JOIN  Snoopy.tbl_Nazioni domi ON d.DomicilioID = domi.NazioneID 
WHERE  (DenoID = 99) 
AND [GeneralPurpose].fn_GetGamingLocalDate2(
		d.InsertTimeStampUTC,
		DATEDIFF(hh,d.InsertTimeStampUTC,GeneralPurpose.fn_UTCToLocal(1,d.InsertTimeStampUTC)),
		4 --casse 
		) = c.GamingDate
GROUP BY c.FirstName, 
	c.LastName, 
	c.BirthDate, 
	c.GamingDate , 
	dt.FDescription,
	d.ExpirationDate,
	d.DocNumber,
	d.Address,
	d.DomicilioID,
	domi.FDescription,
	d.CitizenshipID,
	citi.FDescription
GO
