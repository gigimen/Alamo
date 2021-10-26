SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [CasinoLayout].[ValueTypes]
WITH SCHEMABINDING
AS
SELECT 
vt.ValueTypeID,
CASE WHEN vt.ValueTypeID IN (7,8,9,23,24,25,26,27,28) THEN 
	cu.ExchangeRateMultiplier 
	ELSE null END AS ExchangeRateMultiplier,
vt.FName,
cu.IsoName AS CurrencyAcronim,
cu.bd0 AS MinDenomination 
FROM [CasinoLayout].[tbl_ValueTypes] vt
INNER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = vt.CurrencyID 


GO
