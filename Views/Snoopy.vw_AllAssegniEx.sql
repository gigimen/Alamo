SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW [Snoopy].[vw_AllAssegniEx]
WITH SCHEMABINDING
AS
SELECT 
	a.PK_AssegnoID							AS	AssegnoID,
	a.NrAssegno,
	a.CentaxCode, 
	a.FK_BankAccountID						AS	BankAccountID,
	a.FK_ContropartitaID					AS ContropartitaID,
	cp.FK_CashIn_IDCauseID					AS CauseID,
	a.Commissione			,
	a.CreditiGiocoRate		,
	BA.BankName, 
	BA.AccountNr, 
	cu.CustomerID, 
	cu.FirstName, 
    cu.LastName, 
	cu.Sesso,
    cu.BirthDate,
	cu.InsertDate							AS CustInsertDate,
	EMISS.SectorName,
    doc.Address, 
	Snoopy.tbl_IDDocTypes.FDescription			AS DocType,
	doc.DocNumber,
	domi.FDescription						AS StatoDomicilio,
	citi.FDescription						AS Citizenship 	,
	doc.ExpirationDate,
	doc.IDDocumentID,
	doc.InsertTimeStampUTC,
	cu.NrTelefono,
	EMISS.SourceGamingDate					AS GamingDate,
	EMISS.SourceTag							AS Tag,
	EMISS.SourceStockID						AS StockID,
	EMISS.OraLoc							AS EmissionTime,
	GeneralPurpose.fn_UTCToLocal(1,a.ControlTimeStampUTC) AS ControlTime,
	a.ControlDate,
	EMISS.DenoID,
	EMISS.ValueTypeName						AS Valuta,
	EMISS.Quantity							AS EuroCents,
	EMISS.Quantity * EMISS.Denomination		AS Importo,
	EMISS.Quantity * EMISS.Denomination * 
	EMISS.ExchangeRate						AS CHF,
	(EMISS.Quantity * EMISS.Denomination ) 
	/ (1+a.Commissione)						AS EuroNetti,
	(EMISS.Quantity * EMISS.Denomination ) 
	/ (1+a.Commissione)	* EMISS.ExchangeRate AS CHFNetti,
	(EMISS.Quantity * EMISS.Denomination ) 
	* a.Commissione / (1+a.Commissione)		AS CommissioneEuro,
	(EMISS.Quantity * EMISS.Denomination ) 
	* a.Commissione / (1+a.Commissione) 
	* EMISS.ExchangeRate					AS CommissioneCHF,
	EMISS.ExchangeRate,
	EMISS.SourceLifeCycleID					AS EmissLFID,
	EMISS.OperationName,
	emU.LastName  + ' ' + emU.FirstName		AS EmissUserName,
	a.FK_EmissCustTransID					AS EmissCustTransID,
	REDEM.OraLoc							AS RedemptionTime,
	redU.LastName  + ' ' + redU.FirstName	AS RedemUserName,
	a.FK_RedemCustTransID					AS RedemCustTransID,					
	REDEM.SourceLifeCycleID					AS RedemLFID,
--	[GeneralPurpose].[fn_UTCToLocal](1,i.IdentificationDate) as IdentificationDate,
	i.gamingDate							AS IdentificationGamingDate,
	i.IdentificationID,
	ch.ColloquioGamingDate,
	ch.FormIVtimeLoc,
	i.RegID,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL THEN NULL
		ELSE 1
	END IsGoldenClubMember,
	g.GoldenClubCardID,
	g.SMSNumber,
	g.EMailAddress,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) AS StartUseMobileTimeStamp,
	g.IDDocumentID AS GoldenIDDocumentID,
	l.Limite,
	gp.[Scadenza] AS ScadenzaGreenPass

FROM Snoopy.tbl_Assegni a 
	INNER JOIN Snoopy.tbl_CustomerBankAccounts BA	ON a.FK_BankAccountID = BA.BankAccountID 
	INNER JOIN Snoopy.tbl_IDDocuments doc 	ON doc.IDDocumentID = a.FK_IDDocumentID
	INNER JOIN Snoopy.tbl_Customers cu		ON BA.CustomerID = cu.CustomerID 
	INNER JOIN Snoopy.tbl_IDDocTypes 		ON Snoopy.tbl_IDDocTypes.IDDocTypeID = doc.IDDocTypeID 
	INNER JOIN Snoopy.tbl_Nazioni citi 		ON doc.CitizenshipID = citi.NazioneID 
	INNER JOIN Snoopy.tbl_Nazioni domi 		ON doc.DomicilioID   = domi.NazioneID 
	INNER JOIN CasinoLayout.tbl_Contropartite cp 		ON cp.ContropartitaID = a.FK_ContropartitaID 
	INNER JOIN Snoopy.vw_AllCustomerTransactionDenominations EMISS
						ON a.FK_EmissCustTransID = EMISS.CustomerTransactionID 
						AND EMISS.CashInbound = 0
						AND EMISS.CustTRCancelID IS NULL
						AND EMISS.OpTypeID = 9 --cambio assegni
	INNER JOIN [CasinoLayout].[Users] emU ON emU.UserID = EMISS.SourceUserID
	LEFT OUTER JOIN Snoopy.vw_AllCustomerTransactionDenominations REDEM
						ON a.FK_RedemCustTransID = REDEM.CustomerTransactionID 
						AND REDEM.CustTRCancelID IS NULL
	LEFT OUTER JOIN [CasinoLayout].[Users] redU ON redU.UserID = REDEM.SourceUserID
	LEFT OUTER JOIN Snoopy.tbl_Identifications i	ON cu.IdentificationID = i.IdentificationID
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch	ON ch.ChiarimentoID = i.ChiarimentoID
	LEFT OUTER JOIN GoldenClub.tbl_Members g 	ON cu.CustomerID = g.CustomerID AND g.CancelID IS NULL
	LEFT OUTER JOIN Snoopy.tbl_AssegniLimite l ON l.CustomerID = cu.CustomerID
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = cu.CustomerID 	
	
WHERE cu.CustCancelID IS NULL AND EMISS.CustTRCancelID IS NULL






GO
