SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE  VIEW [Accounting].[vw_CurrExchangeRates]
WITH SCHEMABINDING
AS
SELECT 
	'1 €=' + STR(eu.IntRate,4,2) + ' CHF'  + '    Vendita 1 €=' + STR(eu.[SellingRate],4,2) + ' CHF' AS EuroRateBanner,
	'1 €=' + STR(eu.IntRate,4,2) + '    1 $=' + STR(us.IntRate,4,2) + '    1 £='+ STR(gb.IntRate,4,2) + '    Vendita Valuta 1 €=' + STR(eu.[SellingRate],4,2) + ' CHF' AS ExRateBanner
FROM [Accounting].tbl_CurrencyGamingdateRates eu,[Accounting].tbl_CurrencyGamingdateRates gb,[Accounting].tbl_CurrencyGamingdateRates us
WHERE eu.CurrencyID = 0 
AND eu.GamingDate = --'5.28.2017'
	(SELECT MAX(GamingDate) FROM Accounting.tbl_CurrencyGamingdateRates WHERE eu.CurrencyID = 0)
/*
		GeneralPurpose.fn_GetGamingLocalDate2(
		GetUTCDate(),
		--pass current hour difference between local and utc 
		DATEDIFF (hh , GetUTCDate(),GetDate()),
		1 --Tavoli StockTypeID 
		) 
*/
AND gb.GamingDate = eu.GamingDate
AND us.GamingDate = eu.GamingDate
AND gb.CurrencyID = 45
AND us.CurrencyID = 2
GO
