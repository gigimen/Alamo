SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_LastCustomerIDDocument]
WITH SCHEMABINDING
AS
SELECT  
	cust.CustomerID,
	cust.FirstName,
	cust.LastName,
	cust.Sesso,
	cust.BirthDate,
	cust.InsertDate AS CustInsertDate,
	cust.IdentificationID,
	doc.Address,
	domi.FDescription AS Domicilio,
	doc.DomicilioID AS DomicilioID,
	cust.NRTelefono,
	doc.IDDocumentID 	,
	doc.DocNumber 		,
	doc.ExpirationDate 	,
	dt.FDescription + ' ' + doc.DocNumber AS DocInfo,
	citi.FDescription AS Citizenship 	,
	doc.CitizenshipID AS CitizenshipID,
	doc.IDDocTypeID,
	dt.NotForIdentification,
	dt.FDescription AS DocType,
	GeneralPurpose.fn_UTCToLocal(1,doc.InsertTimeStampUTC) AS InsertTimeStampLoc,
	CASE 
		WHEN doc.ExpirationDate < GETUTCDATE() - 1 THEN 1
		ELSE 0
	END AS DocExpired
	
FROM    Snoopy.tbl_IDDocuments doc
INNER JOIN 
(
	SELECT 
		MAX(doc.InsertTimeStampUTC) AS maxtime,
		doc.CustomerID
	FROM Snoopy.tbl_IDDocuments doc
	GROUP BY  doc.CustomerID
) a ON a.CustomerID = doc.CustomerID AND a.maxtime = doc.InsertTimeStampUTC
INNER JOIN  Snoopy.tbl_IDDocTypes dt ON dt.IDDocTypeID = doc.IDDocTypeID 
INNER JOIN  Snoopy.tbl_Customers cust ON cust.CustomerID = doc.CustomerID 
INNER JOIN  Snoopy.tbl_Nazioni citi ON doc.CitizenshipID = citi.NazioneID 
INNER JOIN  Snoopy.tbl_Nazioni domi ON doc.DomicilioID   = domi.NazioneID 
WHERE cust.CustCancelID IS NULL 












GO
