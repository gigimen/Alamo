SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  VIEW [Snoopy].[vw_AllDepositiTransactionDenominations]
WITH SCHEMABINDING
AS
SELECT  Snoopy.tbl_Depositi.DepositoID	,
Snoopy.tbl_Depositi.PrelevCustTransID,
	DepLF.LifeCycleID		,
    DepLF.GamingDate 		,
	Dep.CustomerTransactionID AS DepOnTransID	, 
	GeneralPurpose.fn_UTCToLocal(1,Dep.CustomerTransactionTime) AS CustomerTransactionTime, 
--	Dep.OperationID 		,
	DepValues.CashInbound			,
	Snoopy.tbl_Customers.LastName		,
	Snoopy.tbl_Customers.FirstName		,
	Snoopy.tbl_Customers.CustomerID	,
	ids.InsertTimeStampUTC,
	Snoopy.tbl_Customers.BirthDate		,
	Snoopy.tbl_Customers.InsertDate AS CustInsertDate,
	DepDenos.FName AS DenoName,
	DepDenos.DenoID,
	DepDenos.ValueTypeID,
    DepValues.Quantity,
	DepDenos.Denomination,
	DepValues.ExchangeRate,
    (DepValues.Quantity * DepDenos.Denomination * DepValues.ExchangeRate) AS Importo,
	USOWN.FirstName + ' ' + USOWN.LastName 	AS OwnerName	
FROM Snoopy.tbl_Depositi 
	INNER JOIN Snoopy.tbl_CustomerTransactions Dep ON dep.CustomerTransactionID = Snoopy.tbl_Depositi.DepoCustTransId OR dep.CustomerTransactionID = Snoopy.tbl_Depositi.PrelevCustTransId
	INNER JOIN Accounting.tbl_LifeCycles DepLF ON DepLF.LifeCycleID = Dep.SourceLifeCycleID 
	INNER JOIN Snoopy.tbl_Customers ON Snoopy.tbl_Customers.CustomerID = Dep.CustomerID 
	INNER JOIN FloorActivity.tbl_UserAccesses ON FloorActivity.tbl_UserAccesses.UserAccessID = Dep.UserAccessID 
	INNER JOIN CasinoLayout.Users USOWN	ON FloorActivity.tbl_UserAccesses.UserID = USOWN.UserID 
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactionValues DepValues	ON DepValues.CustomerTransactionID = Dep.CustomerTransactionID 
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations DepDenos	ON DepValues.DenoID = DepDenos.DenoID
	LEFT OUTER JOIN Snoopy.tbl_Identifications ids	ON ids.IdentificationID = Snoopy.tbl_Customers.IdentificationID
WHERE Dep.CustTrCancelID IS NULL  AND Snoopy.tbl_Customers.CustCancelID IS NULL

GO
