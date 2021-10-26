SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [Accounting].[vw_AllEuroTransactions]
WITH SCHEMABINDING
AS
SELECT  
	t.LifeCycleID		,
    lf.GamingDate 		,
	t.TransactionID 	, 
	t.ImportoEuroCents  ,
	t.ExchangeRate		,
	GeneralPurpose.fn_RoundToClosest(t.ImportoEuroCents *  e.IntRate / 100,0.01) AS CHFEquiv,
	CASE
	WHEN t.OpTypeID = 13 THEN 
		CAST(t.ImportoEuroCents AS FLOAT) / 100 * (t.ExchangeRate - e.IntRate) 
		ELSE 0.0
	END AS UtileCambio,
	t.RedeemTransactionID,
	t.FrancsInRedemCents,
	t.LeftToBeRedeemedCents,
	t.PhysicalEuros		,
	s.StockTypeID,
	s.StockID,
	s.Tag,
	t.OpTypeID,
	CASE t.OpTypeID
	WHEN 11 --acquisto
		THEN +1
	WHEN 12 --redemption
		THEN -1
	WHEN 13 --vendita
		THEN -1
	ELSE 
		0
	END AS Multiplier,
	ot.FName		AS OperationName 	,
	t.InsertTimestamp,
	t.UserAccessID,
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
	INNER JOIN [Accounting].[tbl_CurrencyGamingdateRates] e ON e.GamingDate = lf.GamingDate AND e.CurrencyID = 0
	LEFT OUTER JOIN Snoopy.tbl_Customers c 
	ON c.CustomerID = t.CustomerID 
	LEFT OUTER JOIN GoldenClub.tbl_Members g 
	ON g.CustomerID = t.CustomerID 
WHERE   t.CancelID IS NULL






GO
