SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Snoopy].[vw_AllDepositiTransactions]
--WITH SCHEMABINDING
AS

SELECT  d.DepositoID								,
	Dep.SourceLifeCycleID				AS LifeCycleID,
    Dep.GamingDate 		,
	Dep.CustomerTransactionID 	, 
	Dep.OraLoc							AS CustomerTransactionTime, 
	Dep.CashInbound						,
	Dep.CashInbound						AS IsVersamento,
	Dep.LastName		,
	Dep.FirstName		,
	Dep.CustomerID	,
	ids.InsertTimeStampUTC,
	Dep.BirthDate		,
	Dep.Sesso			,
	c.IdentificationGamingDate,
	c.ColloquioGamingDate,
	c.FormIVtimeLoc,
	c.IdentificationID,
	c.NrTelefono,
	dep.CustInsertDate,
	DEp.CurrencyID,
	cur.IsoName AS Acronim,
    Dep.Quantity						AS Importo,
	USOWN.FirstName + ' ' + USOWN.LastName 	AS OwnerName	
FROM Snoopy.tbl_Depositi d
	INNER JOIN Snoopy.vw_AllCustomerTransactions Dep ON dep.CustomerTransactionID = d.DepoCustTransId OR dep.CustomerTransactionID = d.PrelevCustTransId
	INNER JOIN Snoopy.vw_PersoneIdentificate c ON c.CustomerID = dep.CustomerID 
	INNER JOIN CasinoLayout.tbl_Currencies cur ON cur.CurrencyID  = dep.CurrencyID
	INNER JOIN FloorActivity.tbl_UserAccesses ON FloorActivity.tbl_UserAccesses.UserAccessID = Dep.UserAccessID 
	INNER JOIN CasinoLayout.Users USOWN	ON FloorActivity.tbl_UserAccesses.UserID = USOWN.UserID 
	LEFT OUTER JOIN Snoopy.tbl_Identifications ids	ON ids.IdentificationID = dep.IdentificationID




GO
