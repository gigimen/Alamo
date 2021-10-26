SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  VIEW [Snoopy].[vw_AllDepositi]
--WITH SCHEMABINDING
AS
SELECT 
	dep.DepositoID,
	DepOnLF.LifeCycleID				AS DepOnLFID,
    DepOnLF.GamingDate 				AS DepOnGamingdate,
	DepOn.CustomerTransactionID 	AS DepOnTransID, 
	DepOn.CustomerTransactionTime,
	GeneralPurpose.fn_UTCToLocal(1,DepOn.CustomerTransactionTime) 	AS DepOnTransTime, 
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
	DepOnValues.CashInbound,
	ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination),0)  as Quantity,
   	ISNULL(SUM(DepOnValues.Quantity * DepOnDenos.Denomination * DepOnValues.ExchangeRate),0) AS Importo, 
   	ISNULL(SUM(CASE WHEN DepOnDenos.ValueTypeID = 1 then DepOnValues.Quantity * DepOnDenos.Denomination * DepOnValues.ExchangeRate ELSE 0 end),0) AS ImportoSfr, 
   	ISNULL(SUM(CASE WHEN DepOnDenos.ValueTypeID = 36 then DepOnValues.Quantity * DepOnDenos.Denomination * DepOnValues.ExchangeRate ELSE 0 end),0) AS ImportoEuro, 
 	DepOffLF.LifeCycleID			AS DepOffLFID,
    DepOffLF.GamingDate 			AS DepOffGamingdate,
	dep.PrelevCustTransID 			AS DepOffID, 
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
	c.CheckedBy
	
FROM  Snoopy.tbl_Depositi dep
	INNER JOIN  Snoopy.tbl_CustomerTransactions DepOn ON dep.DepoCustTransID = DepOn.CustomerTransactionID AND DepOn.CustTrCancelID IS NULL
	INNER JOIN Accounting.tbl_LifeCycles DepOnLF ON DepOnLF.LifeCycleID = DepOn.SourceLifeCycleID 
	INNER JOIN Snoopy.vw_PersoneIdentificate c ON c.CustomerID = DepOn.CustomerID 
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactionValues DepOnValues ON DepOnValues.CustomerTransactionID = DepOn.CustomerTransactionID 
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations DepOnDenos ON DepOnValues.DenoID = DepOnDenos.DenoID
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactions DepOff	ON dep.PrelevCustTransID = DepOff.CustomerTransactionID AND DepOff.CustTrCancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_LifeCycles DepOffLF ON DepOffLF.LifeCycleID = DepOff.SourceLifeCycleID 
	LEFT OUTER JOIN GoldenClub.tbl_Members g ON c.CustomerID = g.CustomerID AND g.CancelID IS NULL

WHERE DepOn.CustTrCancelID IS NULL AND DepOff.CustTRCancelID IS NULL
GROUP BY 
	dep.DepositoID,
	DepOnLF.LifeCycleID,
	DepOn.CustomerTransactionID, 
	DepOn.CustomerTransactionTime,
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.CustomerID,
	c.BirthDate,
	c.CustInsertDate,
	c.NrTelefono,
	c.IdentificationID,
	c.IdentificationGamingDate,
	c.ColloquioGamingDate,
	c.FormIVtimeLoc,
	c.CategoriaRischio,
	c.RegID,
	c.SMCheckTime,
	c.CheckedBy,
	c.Causale,
	c.ExpirationDate,
	c.IDDocumentID,
	c.SectorName,
	DepOnLF.GamingDate,
	dep.PrelevCustTransID,
	DepOff.CustomerTransactionTime,
	DepOnValues.CashInbound,
	DepOffLF.LifeCycleID,
	DepOffLF.GamingDate,
	g.CustomerID,
	g.CancelID,
	g.GoldenClubCardID,
	g.EMailAddress,
	g.StartUseMobileTimeStampUTC,
	g.SMSNumber,
	g.IDDocumentID,
	c.DocInfo,
	c.Citizenship





GO
