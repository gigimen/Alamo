SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [Accounting].[vw_AllEuroCambi]
WITH SCHEMABINDING
AS
SELECT  
	t.LifeCycleID		,
    lf.GamingDate 		,
	t.TransactionID 	, 
	t.ImportoEuroCents,
	t.RedeemTransactionID,
	GeneralPurpose.fn_UTCToLocal(1,r.InsertTimestamp) AS RedeemTime,
	t.FrancsInRedemCents,
	t.LeftTobeRedeemedCents  ,
	t.PhysicalEuros		,
	t.ExchangeRate		,
	CAST(t.ImportoEuroCents AS FLOAT) / 100 * (t.ExchangeRate - e.IntRate) AS UtileCambio,
	e.IntRate			,
	g.GoldenClubCardID	,
	s.StockTypeID		,
	s.StockID			,
	s.Tag				,
	ot.FName		AS OperationName 	,
	GeneralPurpose.fn_UTCToLocal(1,t.InsertTimestamp) 	AS ora, 
	c.LastName			,
	c.FirstName			,
	c.Sesso				,
	c.CustomerID		,
	c.BirthDate			,
	c.InsertDate AS CustInsertDate,
	c.NrTelefono		,
	1 AS Multiplier
FROM    Accounting.tbl_EuroTransactions t
	INNER JOIN CasinoLayout.OperationTypes ot
	ON ot.OpTypeID = t.OpTypeID 
	INNER JOIN Accounting.tbl_LifeCycles lf 
	ON t.LifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks s 
	ON s.StockID = lf.StockID 
	INNER JOIN Accounting.tbl_CurrencyGamingdateRates e ON e.GamingDate = lf.GamingDate AND e.CurrencyID = 0
	LEFT OUTER JOIN Snoopy.tbl_Customers c 
	ON c.CustomerID = t.CustomerID 
	LEFT OUTER JOIN GoldenClub.tbl_Members g 
	ON g.CustomerID = t.CustomerID 
	LEFT OUTER JOIN Accounting.tbl_EuroTransactions r
	ON r.TransactionID = t.RedeemTransactionID 
WHERE   t.OpTypeID = 11 --only cambios
AND t.CancelID IS NULL



GO
