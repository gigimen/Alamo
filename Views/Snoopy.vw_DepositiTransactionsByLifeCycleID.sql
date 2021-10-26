SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*

select CDep,Deposito,Prelievo,Movement from [Snoopy].[vw_DepositiTransactionsByLifeCycleID] 
where LifeCycleID = 179680 and CurrencyID = 4
*/


CREATE VIEW [Snoopy].[vw_DepositiTransactionsByLifeCycleID]
WITH SCHEMABINDING
AS
SELECT 
	lf.StockID,
	lf.GamingDate,
	lf.LifeCycleID,
	cu.CurrencyID,
	ISNULL(dep.tot,0) + ISNULL(pre.tot,0) AS CDep,
	ISNULL(dep.Importo,0) AS Deposito,	
	ISNULL(pre.Importo,0) AS Prelievo,	
	ISNULL(pre.Importo,0) - ISNULL(dep.Importo,0)AS Movement	
FROM Accounting.tbl_LifeCycles lf
CROSS JOIN CasinoLayout.tbl_Currencies cu
FULL OUTER JOIN 
( 
	/*

	select CDep,Deposito,Prelievo,Movement from [Snoopy].[vw_DepositiTransactionsByLifeCycleID] 
	where LifeCycleID = 179680 and CurrencyID = 4
	*/SELECT 
		COUNT(DISTINCT  dep.CustomerTransactionID) AS tot,
		DepLF.LifeCycleID		,
		vt.CUrrencyID,
		SUM(DepValues.Quantity * DepDenos.Denomination ) AS Quantity,
		SUM(DepValues.Quantity * DepDenos.Denomination * DepValues.ExchangeRate) AS Importo
	FROM Snoopy.tbl_CustomerTransactions Dep 
		INNER JOIN Snoopy.tbl_Depositi ON dep.CustomerTransactionID = Snoopy.tbl_Depositi.DepoCustTransId
		INNER JOIN Accounting.tbl_LifeCycles DepLF ON DepLF.LifeCycleID = Dep.SourceLifeCycleID 
		LEFT OUTER JOIN Snoopy.tbl_CustomerTransactionValues DepValues	ON DepValues.CustomerTransactionID = Dep.CustomerTransactionID 
		LEFT OUTER JOIN CasinoLayout.tbl_Denominations DepDenos	ON DepValues.DenoID = DepDenos.DenoID
		LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes vt	ON vt.ValueTypeID = DepDenos.ValueTypeID
	WHERE Dep.CustTrCancelID IS NULL --and DepLF.LifeCycleID = 179680
	GROUP BY DepLF.LifeCycleID,vt.CUrrencyID
) dep ON dep.LifeCycleID = lf.LifeCycleID AND dep.CurrencyID = cu.CurrencyID
FULL OUTER JOIN 
(
	SELECT 
		COUNT(DISTINCT  dep.CustomerTransactionID) AS tot,
		vt.CUrrencyID,
		DepLF.LifeCycleID		,
		SUM(DepValues.Quantity * DepDenos.Denomination * DepValues.ExchangeRate) AS Importo
	FROM Snoopy.tbl_CustomerTransactions Dep 
		INNER JOIN Snoopy.tbl_Depositi ON dep.CustomerTransactionID = Snoopy.tbl_Depositi.PrelevCustTransID
		INNER JOIN Accounting.tbl_LifeCycles DepLF ON DepLF.LifeCycleID = Dep.SourceLifeCycleID 
		LEFT OUTER JOIN Snoopy.tbl_CustomerTransactionValues DepValues	ON DepValues.CustomerTransactionID = Dep.CustomerTransactionID 
		LEFT OUTER JOIN CasinoLayout.tbl_Denominations DepDenos	ON DepValues.DenoID = DepDenos.DenoID
		LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes vt	ON vt.ValueTypeID = DepDenos.ValueTypeID
	WHERE Dep.CustTrCancelID IS NULL --and DepLF.LifeCycleID = 179680
	GROUP BY DepLF.LifeCycleID,vt.CUrrencyID
) pre ON pre.LifeCycleID = lf.LifeCycleID AND cu.CurrencyID = pre.CurrencyID
WHERE cu.CurrencyID IN(0,4) --AND lf.LifeCycleID = 179680





















GO
