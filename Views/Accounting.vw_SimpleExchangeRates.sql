SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_SimpleExchangeRates]
WITH SCHEMABINDING
AS
SELECT     TOP 100 PERCENT
	e.GamingDate, 
	e.IntRate, 
	e.TableRate, 
	vt.FName AS ValueTypeName, 
    cu.ExchangeRateMultiplier, 
    cu.IsoName AS CurrencyAcronim, 
    cu.bd0 AS MinDenomination, 
    vt.ValueTypeID
FROM Accounting.tbl_CurrencyGamingdateRates e
INNER JOIN CasinoLayout.tbl_Currencies cu ON e.CurrencyID = cu.CurrencyID
INNER JOIN CasinoLayout.tbl_ValueTypes  vt ON vt.CurrencyID = cu.CurrencyID
WHERE vt.ValueTypeID <= 28 --avoid new valutypes in euro
ORDER BY GamingDate DESC




GO
