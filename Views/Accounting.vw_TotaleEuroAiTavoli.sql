SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  VIEW [Accounting].[vw_TotaleEuroAiTavoli]
WITH SCHEMABINDING
AS
SELECT  
	t.LifeCycleID		,
    lf.GamingDate 		,
    COUNT(*) AS NrScontrini,
	SUM(CAST(t.ImportoEuroCents AS FLOAT) / 100) AS TotEuro,
	s.Tag	
FROM    Accounting.tbl_EuroTransactions t
	INNER JOIN CasinoLayout.OperationTypes ot
	ON ot.OpTypeID = t.OpTypeID 
	INNER JOIN Accounting.tbl_LifeCycles lf 
	ON t.LifeCycleID = lf.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks s 
	ON s.StockID = lf.StockID 

WHERE   t.OpTypeID = 11 --only cambios
AND CancelID IS NULL
AND s.StockTypeID = 1
GROUP BY t.LifeCycleID		,
    lf.GamingDate 		,
	s.Tag



































































GO
