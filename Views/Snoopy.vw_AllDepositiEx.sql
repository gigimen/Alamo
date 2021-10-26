SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE  VIEW [Snoopy].[vw_AllDepositiEx]
--WITH SCHEMABINDING
AS
SELECT 
	dep.DepositoID,
	DepOnValues.[SourceLifeCycleID]					AS DepOnLFID,
    DepOnValues.[SourceGamingDate] 					AS DepOnGamingdate,
	DepOnValues.CustomerTransactionID				AS DepOnTransID, 
	DepOnValues.OraUTC								AS DepTimeUTC,
	DepOnValues.OraLoc								AS DepOnTransTime, 
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.CustomerID,
	c.BirthDate,
	c.CustInsertDate,
	c.NrTelefono,
	c.Causale,
	c.CategoriaRischio,
	c.SectorName,
	DepOnValues.CurrencyID,
	DepOnValues.CurrencyAcronim						AS Acronim,
	DepOnValues.CashInbound,
	ISNULL(SUM(DepOnValues.Quantity * DepOnValues.Denomination),0)  AS Quantity,
   	ISNULL(SUM(DepOnValues.Quantity * DepOnValues.Denomination * DepOnValues.ExchangeRate),0) AS Importo, 
 	DepOffLF.LifeCycleID							AS DepOffLFID,
    DepOffLF.GamingDate 							AS DepOffGamingdate,
	dep.PrelevCustTransID 							AS DepOffID, 
	GeneralPurpose.fn_UTCToLocal(1,DepOff.CustomerTransactionTime) 	AS DepOffTransTime,
	c.IdentificationID,
	c.IdentificationGamingDate,
	c.ColloquioGamingDate,
	c.FormIVtimeLoc,
	c.RegID,
	c.ExpirationDate,
	c.IDDocumentID,
	c.DocInfo,
	c.Citizenship,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL THEN NULL
		ELSE 1
	END IsGoldenClubMember,
	g.GoldenClubCardID,
	g.EMailAddress,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) AS StartUseMobileTimeStamp,
	g.SMSNumber,
	g.IDDocumentID AS GoldenIDDocumentID,
	c.SMCheckTime,
	c.CheckedBy,
	gp.[Scadenza] AS ScadenzaGreenPass
	
FROM Snoopy.tbl_Depositi dep
	INNER JOIN  Snoopy.tbl_CustomerTransactions DepOn ON dep.DepoCustTransID = DepOn.CustomerTransactionID AND DepOn.CustTrCancelID IS NULL
	INNER JOIN Snoopy.vw_PersoneIdentificate c ON c.CustomerID = DepOn.CustomerID 
	INNER JOIN [Snoopy].[vw_AllCustomerTransactionDenominations] DepOnValues ON DepOnValues.CustomerTransactionID = DepOn.CustomerTransactionID 
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactions DepOff	ON dep.PrelevCustTransID = DepOff.CustomerTransactionID AND DepOff.CustTrCancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_LifeCycles DepOffLF ON DepOffLF.LifeCycleID = DepOff.SourceLifeCycleID 
	LEFT OUTER JOIN GoldenClub.tbl_Members g ON c.CustomerID = g.CustomerID AND g.CancelID IS NULL
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = c.CustomerID 	
WHERE DepOff.CustTRCancelID IS NULL
GROUP BY 
	dep.DepositoID,
	DepOnValues.[SourceLifeCycleID]					,
    DepOnValues.[SourceGamingDate] 					,
	DepOnValues.CustomerTransactionID				,
	DepOnValues.OraUTC								,
	DepOnValues.OraLoc								,
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.CustomerID,
	c.BirthDate,
	c.CustInsertDate,
	c.NrTelefono,
	c.Causale,
	c.CategoriaRischio,
	c.SectorName,
	DepOnValues.CurrencyID							,
	DepOnValues.CurrencyAcronim						,
	DepOnValues.CashInbound,
	DepOffLF.LifeCycleID			,
    DepOffLF.GamingDate 			,
	dep.PrelevCustTransID 			,
	DepOff.CustomerTransactionTime,
	c.IdentificationID,
	c.IdentificationGamingDate,
	c.ColloquioGamingDate,
	c.FormIVtimeLoc,
	c.RegID,
	c.ExpirationDate,
	c.IDDocumentID,
	c.DocInfo,
	c.Citizenship,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL THEN NULL
		ELSE 1
	END ,
	g.GoldenClubCardID,
	g.EMailAddress,
	g.StartUseMobileTimeStampUTC,
	g.SMSNumber,
	g.IDDocumentID,
	c.SMCheckTime,
	c.CheckedBy,
	gp.[Scadenza]










GO
