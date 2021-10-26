SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_AllChiusuraTavoliDenominations]
WITH SCHEMABINDING
AS
SELECT 
st.Tag, 
lf.StockID,
lf.GamingDate,
lf.StockCompositionID,
DATEPART(mm,lf.GamingDate) AS GamingMonth,
DATEPART(yy,lf.GamingDate) AS GamingYear,
lf.LifeCycleID,
d.FDescription,
d.DenoID,
d.Denomination,
sd.InitialQty,
sd.WeightInTotal,
sd.ModuleValue,
vt.ValueTypeID,
vt.FName AS ValutTypeName,
vt.CurrencyID
FROM Accounting.tbl_LifeCycles lf
INNER JOIN CasinoLayout.Stocks st ON lf.StockID =st.StockID 
INNER JOIN CasinoLayout.StockComposition_Denominations sd	ON sd.StockCompositionID = lf.StockCompositionID
INNER JOIN CasinoLayout.tbl_Denominations d	ON d.DenoID = sd.DenoID
INNER JOIN CasinoLayout.tbl_ValueTypes vt	ON d.ValueTypeID = vt.ValueTypeID
WHERE sd.IsRiserva = 0
and st.StockTypeID = 1




GO
