SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [CasinoLayout].[vw_AllStockCompositionTotals]
--WITH SCHEMABINDING
AS
SELECT 
	StockCompositionID, 
	CompName, 
	CompDescription,	
	StartOfUseGamingDate,
	EndOfUseGamingDate,
	Tag, 
	StockID, 
	StockTypeId,
	Comment, 
	GeneralPurpose.fn_UTCToLocal(1,CreationDate) AS CreationDate, 
	ISNULL(SUM(Denomination * InitialQty),0) AS Totale,
	COUNT(DISTINCT DenoID) AS DenoCount
FROM    [CasinoLayout].[vw_AllStockCompositions]
GROUP BY StockCompositionID, 
Tag, 
StockID, 
StockTypeId,
Comment, 
CreationDate,
CompName, 
CompDescription,	
StartOfUseGamingDate,
EndOfUseGamingDate



GO
