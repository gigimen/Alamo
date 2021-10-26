SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [CasinoLayout].[vw_AllStockCompositionDenominations]
WITH SCHEMABINDING
AS
SELECT  
sc.StockCompositionID, 
sc.FName				AS CompName, 
sc.FDescription			AS CompDescription,	
sc.CreationDate, 
st.Stocks,
vt.ValueTypeID, 
vt.FName				AS ValueTypeName, 
cu.CurrencyID			,
cu.ExchangeRateMultiplier, 
cu.IsoName				AS CurrencyAcronim, 
cu.bd0					AS MinDenomination, 
d.FName					,
d.FDescription			, 
d.IsFisical				, 
d.Denomination, 
d.DenoID, 
d.DoNotDisplayQuantity, 
sd.InitialQty, 
sd.AutomaticFill, 
sd.AllowNegative, 
sd.ModuleValue, 
sd.WeightInTotal,
sd.IsRiserva
FROM  CasinoLayout.StockCompositions sc
LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations sd ON sc.StockCompositionID = sd.StockCompositionID 
LEFT OUTER JOIN CasinoLayout.tbl_Denominations d ON sd.DenoID = d.DenoID 
LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = d.ValueTypeID
LEFT OUTER JOIN CasinoLayout.tbl_Currencies cu ON vt.CurrencyID = cu.CurrencyID
LEFT OUTER JOIN
(
SELECT scs.StockCompositionID,
GeneralPurpose.GroupConcat(st.Tag) AS Stocks
FROM  CasinoLayout.[tbl_StockComposition_Stocks] scs 
LEFT OUTER JOIN CasinoLayout.Stocks st ON st.StockID = scs.StockID 
GROUP BY scs.StockCompositionID
) st ON st.StockCompositionID = sc.StockCompositionID
WHERE sd.Isriserva =0









GO
