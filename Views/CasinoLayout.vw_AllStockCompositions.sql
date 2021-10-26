SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [CasinoLayout].[vw_AllStockCompositions]
WITH SCHEMABINDING
AS
SELECT sc.StockCompositionID, 
sc.FName				AS CompName, 
sc.FDescription			AS CompDescription,	
st.StockID, 
st.Tag, 
st.StockTypeID, 
st.MinBet, 
scs.StartOfUseGamingDate,
scs.EndOfUseGamingDate,
CasinoLayout.StockTypes.FDescription AS StockTypeName, 
CasinoLayout.StockTypes.ChangeOfGamingDate, 
vt.ValueTypeID, 
vt.CurrencyID,
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
scd.IsRiserva,
cu.ExchangeRateMultiplier, 
cu.IsoName AS CurrencyAcronim, 
cu.BD0 AS MinDenomination, 
sc.CreationDate, 
sc.FName AS Comment
FROM         CasinoLayout.StockCompositions sc
LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations scd ON sc.StockCompositionID = scd.StockCompositionID 
LEFT OUTER JOIN CasinoLayout.tbl_Denominations den ON scd.DenoID = den.DenoID 
LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = den.ValueTypeID
LEFT OUTER JOIN CasinoLayout.tbl_Currencies cu ON vt.CurrencyID = cu.CurrencyID
LEFT OUTER JOIN CasinoLayout.tbl_StockComposition_Stocks scs ON sc.StockCompositionID = scs.StockCompositionID 
LEFT OUTER JOIN CasinoLayout.Stocks st ON st.StockID = scs.StockID 
LEFT OUTER JOIN CasinoLayout.StockTypes ON CasinoLayout.StockTypes.StockTypeID = st.StockTypeID 
WHERE scd.IsRiserva IS NULL OR scd.IsRiserva = 0





GO
