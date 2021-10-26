SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Snoopy].[vw_AssegniNominativi]
WITH SCHEMABINDING
AS
SELECT 
	a.PK_AssegnoID AS AssegnoID,
	a.NrAssegno,
	a.CentaxCode, 
	GeneralPurpose.fn_ProperCase(BA.BankName,DEFAULT,DEFAULT)				AS Banca, 
	BA.AccountNr			AS CC, 
	GeneralPurpose.fn_ProperCase(cu.LastName,DEFAULT,DEFAULT) + ' ' + 
	GeneralPurpose.fn_ProperCase(cu.FirstName,DEFAULT,DEFAULT) 
							AS Cliente,
    cu.BirthDate			AS [nato il],
    doc.Address				AS Indirizzo, 
	doc.DocNumber			AS Documento,
	citi.FDescription		AS Nazionalita 	,
	cu.NrTelefono,
	EMISS.SourceGamingDate	AS GamingDate,
	EMISS.OraLoc			AS DataeOra,
	EMISS.Quantity			AS EuroCents,
	EMISS.Quantity * EMISS.Denomination AS Importo,
	EMISS.Quantity * EMISS.Denomination * EMISS.ExchangeRate AS CHF,
	CASE WHEN a.FK_RedemCustTransID IS NULL THEN 1 ELSE 0 END AS Negoziato
FROM Snoopy.tbl_Assegni a 
	INNER JOIN Snoopy.tbl_CustomerBankAccounts BA	ON a.FK_BankAccountID = BA.BankAccountID 
	INNER JOIN Snoopy.tbl_Customers cu		ON BA.CustomerID = cu.CustomerID 
	INNER JOIN Snoopy.tbl_IDDocuments doc 	ON doc.IDDocumentID = a.FK_IDDocumentID
	INNER JOIN Snoopy.tbl_Nazioni citi 		ON doc.CitizenshipID = citi.NazioneID 
	INNER JOIN Snoopy.vw_AllCustomerTransactionDenominations EMISS
						ON a.FK_EmissCustTransID = EMISS.CustomerTransactionID 
						AND EMISS.CashInbound = 0
						AND EMISS.CustTRCancelID IS NULL
						AND EMISS.OpTypeID = 9 --cambio assegni
	LEFT OUTER JOIN Snoopy.vw_AllCustomerTransactionDenominations REDEM
						ON a.FK_RedemCustTransID = REDEM.CustomerTransactionID 
						AND REDEM.CustTRCancelID IS NULL
WHERE cu.CustCancelID IS NULL AND EMISS.CustTRCancelID IS NULL





GO
