SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_AllCustomerTransactionDenominations]
WITH SCHEMABINDING
AS
SELECT  SourceStock.Tag 			AS SourceTag, 
	SourceStock.StockID 			AS SourceStockID, 
	SourceStock.StockTypeID 		AS SourceStockTypeID, 
	Snoopy.tbl_CustomerTransactions.SourceLifeCycleID,
	Accounting.tbl_LifeCycles.GamingDate		AS SourceGamingDate, 
	Snoopy.tbl_CustomerTransactions.CustomerID,
	CUST.FirstName,
	CUST.LastName,
	CUST.Sesso,
	CUST.BirthDate,
	CUST.InsertDate as CustInsertDate,
	CUST.IdentificationID,
	CUST.NrTelefono,
	sec.SectorName,
    CasinoLayout.OperationTypes.OpTypeID, 
	CasinoLayout.OperationTypes.FName		AS OperationName, 
	Snoopy.tbl_CustomerTransactions.CustomerTransactionID, 
	Snoopy.tbl_CustomerTransactions.CustomerTransactionTime		      as OraUTC,
	GeneralPurpose.fn_UTCToLocal(1,Snoopy.tbl_CustomerTransactions.CustomerTransactionTime) as OraLoc,
	Snoopy.tbl_CustomerTransactions.UserAccessID,
	SUAID.UserID				as SourceUserID,
	SUAID.UserGroupID			as SourceUserGroupID,
	Snoopy.tbl_CustomerTransactions.CustTRCancelID, 
	Snoopy.tbl_CustomerTransactionValues.Quantity, 
	Snoopy.tbl_CustomerTransactionValues.ExchangeRate, 
	Snoopy.tbl_CustomerTransactionValues.CashInbound, 	
	vt.ValueTypeID,
	vt.FName					AS ValueTypeName,
	cu.CurrencyID,
	cu.IsoName					AS CurrencyAcronim,
	den.FName									AS DenoName,
	den.FDescription,	
	den.IsFisical, 
	den.Denomination,
	den.DenoID
	FROM    Snoopy.tbl_CustomerTransactions 
 	INNER JOIN Snoopy.tbl_Customers 		CUST 		ON CUST.CustomerID = Snoopy.tbl_CustomerTransactions.customerID 
	INNER JOIN FloorActivity.tbl_UserAccesses 		SUAID 		ON SUAID.UserAccessID = Snoopy.tbl_CustomerTransactions.UserAccessID 
    INNER JOIN CasinoLayout.OperationTypes 				ON CasinoLayout.OperationTypes.OpTypeID = Snoopy.tbl_CustomerTransactions.OpTypeID 
    INNER JOIN Accounting.tbl_LifeCycles 				ON Accounting.tbl_LifeCycles.LifeCycleID = Snoopy.tbl_CustomerTransactions.SourceLifeCycleID 
    INNER JOIN CasinoLayout.Stocks 			SourceStock 	ON SourceStock.StockID = Accounting.tbl_LifeCycles.StockID
    LEFT OUTER JOIN Snoopy.tbl_CustomerTransactionValues 		ON Snoopy.tbl_CustomerTransactionValues.CustomerTransactionID = Snoopy.tbl_CustomerTransactions.CustomerTransactionID
    LEFT OUTER JOIN CasinoLayout.Sectors sec 			ON sec.SectorID = CUST.SectorID 
    LEFT OUTER JOIN CasinoLayout.tbl_Denominations den 			ON den.DenoID = Snoopy.tbl_CustomerTransactionValues.DenoID 
	LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes 	vt			ON den.ValueTypeID = vt.ValueTypeID
	LEFT OUTER JOIN CasinoLayout.tbl_Currencies 	cu			ON cu.CurrencyID = vt.CurrencyID
WHERE  (Snoopy.tbl_CustomerTransactions.CustTrCancelID is null) AND CUST.CustCancelID is NULL

GO
