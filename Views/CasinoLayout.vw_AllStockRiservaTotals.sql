SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [CasinoLayout].[vw_AllStockRiservaTotals]
WITH SCHEMABINDING
AS
SELECT 
	StockCompositionID, 
	Tag, 
	StockID, 
	StockTypeId,
	GeneralPurpose.fn_UTCToLocal(1,StartOfUseGamingDate) as StartOfUseGamingDate, 
	GeneralPurpose.fn_UTCToLocal(1,EndOfUseGamingDate) as EndOfUseGamingDate,
	IsNUll(SUM(Denomination * InitialQty),0) AS Totale
FROM    [CasinoLayout].[vw_AllStockRiservaDenominations]
GROUP BY StockCompositionID, Tag, StockID, StockTypeId, StartOfUseGamingDate,EndOfUseGamingDate

GO
