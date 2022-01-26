SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [CasinoLayout].[vw_AllStockCompositionTotalsByCurrency]
--WITH SCHEMABINDING
AS


SELECT 
		ISNULL(c.StockCompositionID		,e.StockCompositionID		)	AS StockCompositionID				,
		ISNULL(c.CompName				,e.CompName				 	)	AS CompName				 		,
		ISNULL(c.CompDescription		,e.CompDescription			)	AS CompDescription				,
		ISNULL(c.StartOfUseGamingDate	,e.StartOfUseGamingDate		)	AS StartOfUseGamingDate			,
		ISNULL(c.EndOfUseGamingDate		,e.EndOfUseGamingDate		)	AS EndOfUseGamingDate				,
		ISNULL(c.Tag					,e.Tag					 	)	AS Tag					 		,
		ISNULL(c.StockID				,e.StockID				 	)	AS StockID				 		,
		ISNULL(c.StockTypeId			,e.StockTypeId				)	AS StockTypeId					,
		ISNULL(c.Comment				,e.Comment				 	)	AS Comment				 		,
		ISNULL(c.CreationDate			,e.CreationDate			 	)	AS CreationDate			 		,
		ISNULL(c.Totale,0)												AS TotaleCHF,
		ISNULL(c.DenoCount,0)											AS DenocCountCHF,
		ISNULL(e.Totale,0)												AS TotaleEUR,
		ISNULL(e.DenoCount,0)											AS DenoCountEUR

FROM
(
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
	WHERE CurrencyID = 0
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
) e
FULL OUTER JOIN 
(
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
	WHERE CurrencyID = 4
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
) c ON e.StockCompositionID = c.StockCompositionID AND e.StockID = c.StockID



GO
