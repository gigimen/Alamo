SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE  VIEW [Accounting].[vw_AllEuroVendite]
WITH SCHEMABINDING
AS
SELECT  
	t.LifeCycleID		,
    lf.GamingDate 		,
	t.TransactionID 	, 
	t.ImportoEuroCents	,
	t.ExchangeRate		,
	e.IntRate,
	CAST(t.ImportoEuroCents AS FLOAT) / 100 * (t.ExchangeRate - e.IntRate) AS UtileCambio,
	t.RedeemTransactionID,
	t.FrancsInRedemCents,
	t.LeftTobeRedeemedCents,
	t.PhysicalEuros		,
	s.StockTypeID,
	s.StockID,
	s.Tag,
	ot.FName		AS OperationName 	,
	GeneralPurpose.fn_UTCToLocal(1,t.InsertTimestamp) 	AS ora, 
	c.LastName,
	c.FirstName,
	c.Sesso,
	c.CustomerID,
	g.GoldenClubCardID,
	c.BirthDate,
	c.InsertDate AS CustInsertDate,
	c.NrTelefono
FROM    Accounting.tbl_EuroTransactions t
	INNER JOIN CasinoLayout.OperationTypes ot
	ON ot.OpTypeID = t.OpTypeID 
	INNER JOIN Accounting.tbl_LifeCycles lf 
	ON t.LifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks s 
	ON s.StockID = lf.StockID 
	INNER JOIN Accounting.tbl_CurrencyGamingdateRates e ON e.GamingDate = lf.GamingDate AND e.CurrencyID = 0 --euros currency
	LEFT OUTER JOIN Snoopy.tbl_Customers c 
	ON c.CustomerID = t.CustomerID 
	LEFT OUTER JOIN GoldenClub.tbl_Members g 
	ON g.CustomerID = t.CustomerID 
	
WHERE   t.OpTypeID = 13 --only vendite
AND t.CancelID IS NULL








GO
