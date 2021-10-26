SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE  VIEW [Snoopy].[vw_AllCartediCreditoEx]
WITH SCHEMABINDING
AS
SELECT  cu.SourceTag 			AS Tag, 
	cu.SourceLifeCycleID		AS LifeCycleID,
	cu.SourceStockID			AS StockID,
	cu.SourceStockTypeID		AS StockTypeID,
	cu.SourceGamingDate			AS GamingDate, 
	cc.CreditCardTransID,
	cc.FK_ContropartitaID,
	cc.FK_CustomerTransactionID	AS CustomerTransactionID,
	cc.FK_EuroTransactionID		AS EuroTransactionID,
	contp.[FK_CashIn_IDCauseID] AS CauseID,	
	0 AS [FrancsInCaricCents],
	cc.Commissione,
	CAST (CASE WHEN contp.ContropartitaID IN(1,2) THEN 1 ELSE 0 END  AS BIT) AS PrelievoEuro,
	CASE WHEN contp.ContropartitaID IN(1,2) THEN 1.0 ELSE cu.ExchangeRate END AS CreditiGiocoRate,
	cu.OraUTC					AS TransTime,
	cu.OraLoc 					AS ora,
	cu.Quantity,
	cu.DenoID,
	cu.Denomination,
	cu.ExchangeRate,
	CASE WHEN cu.DenoID IN(174, 99) /* Aduno */ THEN (cu.Quantity * cu.Denomination) / (1+cc.Commissione) * cc.Commissione * cu.ExchangeRate ELSE NULL END AS CommisioneInSfr,
	CASE WHEN cu.DenoID IN(174, 99) /* Aduno */ THEN cu.Quantity * cu.Denomination ELSE NULL END AS EuroAtTerminal,
	CASE WHEN cu.DenoID IN(174, 99) /* Aduno */ THEN (cu.Quantity * cu.Denomination) /(1.0 + cc.Commissione) ELSE NULL END AS EuroNetti,	
	CASE WHEN cu.DenoID IN(174, 99) /* Aduno */ THEN (cu.Quantity * cu.Denomination) *  cc.Commissione /(1.0 + cc.Commissione) ELSE NULL END AS CommissioneEuro,
	CASE WHEN cu.DenoID IN(174, 99) /* Aduno */ THEN (cu.Quantity * cu.Denomination) *  cc.Commissione /(1.0 + cc.Commissione) * cu.ExchangeRate ELSE NULL END AS CommissioneCHF,
	CASE WHEN cu.DenoID IN(174, 99) /* Aduno */ THEN NULL ELSE CAST(cu.Quantity * cu.Denomination AS FLOAT) END AS CHF,
	eu.FrancsInRedemCents,
	eu.OpTypeID,
	eu.PhysicalEuros,
	cc.[FK_IDDocumentID] AS IDDocumentID,
	cu.CustomerID,
	cu.FirstName, 
    cu.LastName, 
	cu.Sesso,
    cu.BirthDate,
	cu.CustInsertDate,
	cu.CashInbound,
	cu.SectorName,
	contp.FName AS TipoTrans,
	ide.IdentificationID,
	ide.gamingDate AS IdentificationGamingDate,
	ch.ColloquioGamingDate AS ColloquioGamingDate,
	ch.FormIVtimeLoc,
	cu.NrTelefono,
	CASE 
		WHEN g.CustomerID IS NULL OR g.CancelID IS NOT NULL THEN NULL
		ELSE 1
	END IsGoldenClubMember,
	g.GoldenClubCardID,
	g.EMailAddress,
	GeneralPurpose.fn_UTCToLocal(1,g.StartUseMobileTimeStampUTC) AS StartUseMobileTimeStamp,
	g.SMSNumber,
	g.IDDocumentID AS GoldenIDDocumentID,
	CAST (CASE WHEN eu.CustomerID = cu.CustomerID THEN 1 ELSE NULL END AS BIT) AS UsedGoldenEuro,
	gp.[Scadenza] AS ScadenzaGreenPass
FROM Snoopy.tbl_CartediCredito cc
	FULL OUTER JOIN GeneralPurpose.ConfigParams cp ON cp.VarName = 'CommissioneEuroAduno'
	INNER JOIN Snoopy.vw_AllCustomerTransactionDenominations cu	ON cc.[FK_CustomerTransactionID] = cu.CustomerTransactionID AND cu.optypeid = 10 --carte di credito
	INNER JOIN CasinoLayout.tbl_Contropartite contp ON cc.FK_ContropartitaID = contp.ContropartitaID
	LEFT OUTER JOIN Snoopy.tbl_IDCauses ii ON contp.[FK_CashIn_IDCauseID] = ii.IDCauseID
	LEFT OUTER JOIN Snoopy.tbl_Identifications ide ON ide.IdentificationID = cu.IdentificationID	
	LEFT OUTER JOIN Snoopy.tbl_Chiarimenti ch ON ch.ChiarimentoID = ide.ChiarimentoID
	LEFT OUTER JOIN GoldenClub.tbl_Members g ON cu.CustomerID = g.CustomerID AND g.CancelID IS NULL
	LEFT OUTER JOIN Accounting.tbl_EuroTransactions eu ON eu.TransactionID = cc.FK_EuroTransactionID
	LEFT OUTER JOIN [Snoopy].[tbl_GreenPass] gp ON gp.CustomerID = cu.CustomerID 	







GO
