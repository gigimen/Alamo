SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE  VIEW [Snoopy].[vw_AllBonifici]
WITH SCHEMABINDING
AS
SELECT  TOP 100 PERCENT
	b.BonificoID,
	b.BankAccountID,
	BA.BankName, 
	BA.AccountNr, 
	BA.IBAN,
	BA.SWIFT,
	BA.BankAddress,
	c.CustomerID, 
	c.FirstName, 
        c.LastName, 
	c.Sesso,
        c.BirthDate,
	c.InsertDate AS CustInsertDate,
        doc.Address, 
	sec.SectorName,
	Snoopy.tbl_IDDocTypes.FDescription AS DocType,
	doc.DocNumber,
	domi.FDescription AS StatoDomicilio,
	citi.FDescription AS Citizenship 	,
	doc.ExpirationDate,
	doc.IDDocumentID,
	doc.InsertTimeStampUTC,
	c.NrTelefono,
	ORDE.SourceGamingDate AS GamingDate,
	ORDE.SourceTag AS Tag,
	ORDE.SourceStockID AS StockID,
	ORDE.SourceStockTypeID AS StockTypeID,
	ORDE.OraLoc AS ORDERTime,
	ORDE.DenoID,
	ORDE.ValueTypeName AS Valuta,
	ORDE.Quantity AS EuroCents,
	ORDE.Quantity * ORDE.Denomination AS Euros,
	ORDE.Quantity * ORDE.Denomination * ORDE.ExchangeRate AS CHF,
	b.IsFromEuroCredits,
	ORDE.ExchangeRate,
	ORDE.SourceLifeCycleID	AS ORDERLFID,
	ORDE.OperationName,
	b.OrderCustTransID,
	GeneralPurpose.fn_UTCToLocal(1,b.ExecTimeStampUTC) AS ExecTime,
--	[GeneralPurpose].[fn_UTCToLocal2](1,i.IdentificationDate) as IdentificationDate,
	i.gamingDate AS IdentificationGamingDate,
	i.IdentificationID,
	ch.ColloquioGamingDate,
	ch.FormIVtimeLoc,
	i.RegID,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL THEN NULL
		ELSE 1
	END IsGoldenClubMember,
	g.GoldenClubCardID,
	g.EMailAddress,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) AS StartUseMobileTimeStamp,
	g.SMSNumber,
	g.IDDocumentID AS GoldenIDDocumentID,
	gp.[Scadenza] AS ScadenzaGreenPass
FROM    Snoopy.tbl_Bonifici b 
	INNER JOIN Snoopy.tbl_CustomerBankAccounts BA	ON b.BankAccountID = BA.BankAccountID 
	INNER JOIN Snoopy.tbl_Customers c		ON BA.CustomerID = c.CustomerID 
	INNER JOIN Snoopy.tbl_IDDocuments doc 		ON doc.IDDocumentID = b.IDDocumentID
	INNER JOIN Snoopy.tbl_IDDocTypes 		ON Snoopy.tbl_IDDocTypes.IDDocTypeID = doc.IDDocTypeID 
	INNER JOIN Snoopy.tbl_Nazioni citi 		ON doc.CitizenshipID = citi.NazioneID 
	INNER JOIN Snoopy.tbl_Nazioni domi 		ON doc.DomicilioID   = domi.NazioneID 
	INNER JOIN Snoopy.vw_AllCustomerTransactionDenominations ORDE
						ON b.OrderCustTransID = ORDE.CustomerTransactionID 
						AND ORDE.CashInbound = 1
						AND ORDE.CustTRCancelID IS NULL
						AND ORDE.OpTypeID = 14 --bonifico bancario
	LEFT OUTER JOIN Snoopy.tbl_Identifications i	ON c.IdentificationID = i.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch	ON ch.ChiarimentoID = i.ChiarimentoID
	LEFT OUTER JOIN GoldenClub.tbl_Members g 	ON c.CustomerID = g.CustomerID AND g.CancelID IS NULL
	LEFT OUTER JOIN CasinoLayout.Sectors sec on sec.SectorID = c.SectorID
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = c.CustomerID 	
WHERE c.CustCancelID IS NULL AND ORDE.CustTRCancelID IS NULL
ORDER BY ORDERTime




GO
