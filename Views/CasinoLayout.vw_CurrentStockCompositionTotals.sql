SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [CasinoLayout].[vw_CurrentStockCompositionTotals]
WITH SCHEMABINDING
AS
SELECT 
	StockCompositionID, 
	CompName, 
	CompDescription,	
	StartOfUseGamingDate,
	EndOfUseGamingDate,
	Tag, 
	Stocks as AltriStocks,
	StockID, 
	StockTypeId,
	IsNUll(SUM(Denomination * InitialQty),0) AS Totale
FROM    [CasinoLayout].[vw_CurrentStockDenominations]
GROUP BY	
StockCompositionID, 
	CompName, 
	CompDescription,	
	StartOfUseGamingDate,
	EndOfUseGamingDate,
	Tag, 
	Stocks,
	StockID, 
	StockTypeId







GO
