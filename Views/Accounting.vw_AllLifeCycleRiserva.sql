SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Accounting].[vw_AllLifeCycleRiserva]
WITH SCHEMABINDING
AS
SELECT 
	sc.StockCompositionID,
	stocks.Stocks,
	lf.LifeCycleID,
	lf.GamingDate,
	lf.StockID, 
	st.Tag, 
	st.StockTypeID, 
	st.MinBet,
	CasinoLayout.StockTypes.FDescription AS StockTypeName,
	CasinoLayout.StockTypes.ChangeOfGamingDate,
	vt.ValueTypeID, 
	vt.FName AS ValueTypeName, 
	de.FName, 
	de.FDescription, 
	de.IsFisical, 
	de.Denomination, 
    de.DenoID, 
	de.DoNotDisplayQuantity,
	code.InitialQty, 
	code.AutomaticFill,
	code.AllowNegative,
 	code.ModuleValue, 
	code.WeightInTotal, 
	cu.CurrencyID,
	cu.ExchangeRateMultiplier, 
    cu.IsoName AS  CurrencyAcronim,
	cu.bd0 AS MinDenomination
FROM    Accounting.tbl_LifeCycles lf INNER JOIN CasinoLayout.Stocks st ON st.StockID = lf.StockID
INNER JOIN CasinoLayout.StockTypes ON CasinoLayout.StockTypes.StockTypeID = st.StockTypeID
INNER JOIN CasinoLayout.StockCompositions sc ON sc.StockCompositionID = lf.StockCompositionID
INNER JOIN CasinoLayout.StockComposition_Denominations code ON sc.StockCompositionID = code.StockCompositionID
INNER JOIN CasinoLayout.tbl_Denominations de ON code.DenoID = de.DenoID
INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = de.ValueTypeID
INNER JOIN CasinoLayout.tbl_Currencies cu ON vt.CurrencyID = cu.CurrencyID
LEFT OUTER JOIN
(
	SELECT sc.StockCompositionID,
	GeneralPurpose.GroupConcat(st.Tag) AS Stocks
	FROM CasinoLayout.StockCompositions sc
	LEFT OUTER JOIN CasinoLayout.[tbl_StockComposition_Stocks] scs ON sc.StockCompositionID = scs.StockCompositionID 
	LEFT OUTER JOIN CasinoLayout.Stocks st ON st.StockID = scs.StockID 
	GROUP BY sc.StockCompositionID
) stocks ON stocks.StockCompositionID = sc.StockCompositionID
WHERE code.IsRiserva =1






GO
