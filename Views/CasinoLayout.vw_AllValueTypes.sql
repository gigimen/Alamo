SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [CasinoLayout].[vw_AllValueTypes]
WITH SCHEMABINDING
AS
SELECT 
vt.ValueTypeID,
CASE WHEN cu.ExchangeRateMultiplier = 0 THEN NULL ELSE cu.ExchangeRateMultiplier END AS ExchangeRateMultiplier,
vt.FName,
vt.FDescription,
cu.IsoName AS CurrencyAcronim,
cu.bd0 AS MinDenomination ,
CAST(CASE WHEN vt.CurrencyID = 4 THEN 0 ELSE 1 END AS BIT) AS IsForeignCurrency,
vt.CurrencyID
FROM [CasinoLayout].[tbl_ValueTypes] vt
INNER JOIN CasinoLayout.tbl_Currencies cu ON cu.CurrencyID = vt.CurrencyID 



GO
