SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [CasinoLayout].[vw_AllLifeCycleInitialValues]
WITH SCHEMABINDING
AS
SELECT  TOP 100 PERCENT 
	lf.LifeCycleID,
	CasinoLayout.StockCompositions.StockCompositionID,
	lf.GamingDate,
	st.MinBet,
	st.Tag,
	st.StockID,
--	dbo.Denominations.FDescription,
--	dbo.Stock_Denominations.InitialQty
	SUM(CasinoLayout.StockComposition_Denominations.InitialQty * den.Denomination) AS InitialValue
FROM    Accounting.tbl_LifeCycles lf
	INNER JOIN CasinoLayout.Stocks st
	ON  st.StockID = lf.StockID
	INNER JOIN CasinoLayout.StockCompositions
	ON CasinoLayout.StockCompositions.StockCompositionID = lf.StockCompositionID
	INNER JOIN CasinoLayout.StockComposition_Denominations
	ON CasinoLayout.StockCompositions.StockCompositionID = CasinoLayout.StockComposition_Denominations.StockCompositionID
INNER JOIN CasinoLayout.tbl_Denominations den  
	ON den.DenoID = CasinoLayout.StockComposition_Denominations.DenoID 
WHERE   ( lf.GamingDate >= st.FromGamingDate AND (lf.GamingDate <= st.TillGamingDate OR st.TillGamingDate IS NULL)) 
AND CasinoLayout.StockComposition_Denominations.IsRiserva = 0
/*	--AND (dbo.Stock_Denominations.InitialQty IS NOT NULL) 
	AND (dbo.Denominations.FName <> 'Lucky Chips')
	--avoid counting also initial value of other valuetypes such as Euros
	AND  dbo.Denominations.ValueTypeID in (1,2,3,36) 'Banconote','Monete','Gettoni' */
GROUP BY 
	lf.LifeCycleID,
	lf.GamingDate,
	CasinoLayout.StockCompositions.StockCompositionID,
	st.MinBet,
	st.Tag,
	st.StockID
ORDER BY  lf.GamingDate ASC,st.Tag ASC










GO
