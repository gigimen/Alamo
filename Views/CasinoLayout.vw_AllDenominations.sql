SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [CasinoLayout].[vw_AllDenominations]
WITH SCHEMABINDING
AS
SELECT     
	d.DenoID, 
	d.Denomination, 
	d.FName, 
	d.FDescription, 
	d.IsFisical, 
	d.DoNotDisplayQuantity,
	vt.ValueTypeID, 
	vt.FName AS ValueTypeName, 
	cu.CurrencyID,
	cu.ExchangeRateMultiplier, 
	cu.IsoNAme AS CurrencyAcronim,
	cu.bd0 AS MinDenomination
FROM	CasinoLayout.tbl_Denominations d
	INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = d.ValueTypeID
	INNER JOIN CasinoLayout.tbl_Currencies cu ON vt.CurrencyID = cu.CurrencyID
	
GO
