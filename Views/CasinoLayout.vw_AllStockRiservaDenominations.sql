SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [CasinoLayout].[vw_AllStockRiservaDenominations]
WITH SCHEMABINDING
AS
SELECT
	sc.StockCompositionID,
	sc.CreationDate,
	scs.StartOfUseGamingDate,
	scs.EndOfUseGamingDate,
	st.StockID, 
	st.Tag, 
	st.StockTypeID, 
	st.MinBet,
	sty.FDescription AS StockTypeName,
	sty.ChangeOfGamingDate,
	vt.ValueTypeID, 
    vt.FName AS ValueTypeName, 
	den.FName, 
	den.FDescription, 
	den.IsFisical, 
	den.Denomination, 
    den.DenoID, 
	den.DoNotDisplayQuantity,
	scd.InitialQty, 
	scd.AutomaticFill,
	scd.AllowNegative,
 	scd.ModuleValue, 
	scd.WeightInTotal, 
	cu.CurrencyID,
	cu.ExchangeRateMultiplier, 
    cu.IsoName AS CurrencyAcronim,
	cu.bd0 AS MinDenomination
FROM    CasinoLayout.Stocks st
	INNER JOIN CasinoLayout.StockTypes sty ON sty.StockTypeID = st.StockTypeID
	INNER JOIN CasinoLayout.[tbl_StockComposition_Stocks] scs ON st.StockID = scs.StockID
	INNER JOIN CasinoLayout.StockCompositions sc ON sc.StockCompositionID = scs.StockCompositionID
	INNER JOIN CasinoLayout.StockComposition_Denominations scd ON sc.StockCompositionID = scd.StockCompositionID
	INNER JOIN CasinoLayout.tbl_Denominations den ON scd.DenoID = den.DenoID
	INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID
	INNER JOIN CasinoLayout.tbl_Currencies cu ON vt.CurrencyID = cu.CurrencyID
WHERE scd.IsRiserva = 1 AND scs.EndOfUseGamingDate IS NULL

GO
