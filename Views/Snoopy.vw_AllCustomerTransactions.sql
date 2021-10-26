SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Snoopy].[vw_AllCustomerTransactions]
WITH SCHEMABINDING
AS
SELECT  st.Tag 															AS SourceTag, 
	st.StockID 															AS SourceStockID, 
	st.StockTypeID 														AS SourceStockTypeID, 
	ctr.SourceLifeCycleID,
	lf.GamingDate, 
	ctr.CustomerID,
	cu.FirstName,
	cu.LastName,
	cu.Sesso,
	cu.BirthDate,
	cu.InsertDate														AS CustInsertDate,
	cu.IdentificationID,
	cu.NrTelefono,
    opt.OpTypeID, 
	opt.FName															AS OperationName, 
	ctr.CustomerTransactionID, 
	ctr.CustomerTransactionTime											AS OraUTC,
	GeneralPurpose.fn_UTCToLocal(1,ctr.CustomerTransactionTime)	AS OraLoc,
	ctr.UserAccessID,
	SUAID.UserID														AS SourceUserID,
	SUAID.UserGroupID													AS SourceUserGroupID,
	vt.CurrencyID,
	ISNULL(SUM(v.Quantity * d.Denomination),0)							AS Quantity,
	ISNULL(SUM(v.Quantity * d.Denomination * v.ExchangeRate),0)			AS ValueSfr,
   	ISNULL(SUM(CASE WHEN d.ValueTypeID = 1 THEN v.Quantity * d.Denomination * v.ExchangeRate ELSE 0 END),0) AS ImportoSfr, 
   	ISNULL(SUM(CASE WHEN d.ValueTypeID = 36 THEN v.Quantity * d.Denomination * v.ExchangeRate ELSE 0 END),0) AS ImportoEuro, 
	v.CashInbound														
FROM Snoopy.tbl_CustomerTransactions ctr
 	INNER JOIN Snoopy.tbl_Customers 				cu 			ON cu.CustomerID = ctr.customerID 
	INNER JOIN FloorActivity.tbl_UserAccesses 		SUAID 		ON SUAID.UserAccessID = ctr.UserAccessID 
    INNER JOIN CasinoLayout.OperationTypes 		opt			ON opt.OpTypeID = ctr.OpTypeID 
    INNER JOIN Accounting.tbl_LifeCycles 			lf			ON lf.LifeCycleID = ctr.SourceLifeCycleID 
    INNER JOIN CasinoLayout.Stocks 				st 			ON st.StockID = lf.StockID
	LEFT OUTER JOIN Snoopy.tbl_CustomerTransactionValues v		ON v.CustomerTransactionID = ctr.CustomerTransactionID
    LEFT OUTER JOIN CasinoLayout.tbl_Denominations 		 d		ON d.DenoID = v.DenoID 
    LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes 		 vt		ON d.ValueTypeID = vt.ValueTypeID 
WHERE  (ctr.CustTrCancelID IS NULL) AND cu.CustCancelID IS NULL
GROUP BY st.Tag, 
	st.StockID, 
	st.StockTypeID, 
	ctr.SourceLifeCycleID,
	lf.GamingDate, 
	ctr.CustomerID,
	cu.FirstName,
	cu.LastName,
	cu.Sesso,
	cu.BirthDate,
	cu.InsertDate,
	cu.IdentificationID,
	cu.NrTelefono,
    opt.OpTypeID, 
	opt.FName, 
	ctr.CustomerTransactionID, 
	ctr.CustomerTransactionTime,
	GeneralPurpose.fn_UTCToLocal(1,ctr.CustomerTransactionTime),
	ctr.UserAccessID,
	SUAID.UserID,
	SUAID.UserGroupID,
	vt.CurrencyID,
	v.CashInbound


GO
