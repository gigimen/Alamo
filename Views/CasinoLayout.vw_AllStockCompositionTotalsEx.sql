SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [CasinoLayout].[vw_AllStockCompositionTotalsEx]
WITH SCHEMABINDING
AS
SELECT 
	ISNULL(chf.StockCompositionID, 		   eur.StockCompositionID			 ) AS 	StockCompositionID		  ,
	ISNULL(chf.CompName, 				   eur.CompName						 ) AS 	CompName				  ,
	ISNULL(chf.CompDescription,			   eur.CompDescription				 ) AS 	CompDescription			  ,
	ISNULL(chf.StartOfUseGamingDate,	   eur.StartOfUseGamingDate			 ) AS 	StartOfUseGamingDate	  ,
	ISNULL(chf.EndOfUseGamingDate,		   eur.EndOfUseGamingDate			 ) AS 	EndOfUseGamingDate		  ,
	ISNULL(chf.Tag, 					   eur.Tag							 ) AS 	Tag						  ,
	ISNULL(chf.StockID, 				   eur.StockID						 ) AS 	StockID					  ,
	ISNULL(chf.StockTypeID,				   eur.StockTypeID					 ) AS 	StockTypeID				  ,
	ISNULL(chf.Comment, 				   eur.Comment 						 ) AS 	Comment 				  ,
	ISNULL(chf.Totale,0) AS TotaleCHF,
	ISNULL(eur.Totale,0) AS TotaleEUR,
	ISNULL(chf.DenoCount,0) + ISNULL(eur.DenoCount,0) AS DenoCount
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
		StockTypeID,
		Comment, 		
		ISNULL(SUM(Denomination * InitialQty),0) AS Totale,
		COUNT(DISTINCT DenoID) AS DenoCount
	FROM [CasinoLayout].[vw_AllStockCompositions]
	WHERE CurrencyID = 4
	GROUP BY 
		StockCompositionID, 
		CompName, 
		CompDescription,	
		StartOfUseGamingDate,
		EndOfUseGamingDate,
		Tag, 
		StockID, 
		StockTypeID,
		Comment
) chf
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
		StockTypeID,
		Comment, 		
		ISNULL(SUM(Denomination * InitialQty),0) AS Totale,
		COUNT(DISTINCT DenoID) AS DenoCount
	FROM [CasinoLayout].[vw_AllStockCompositions]
	WHERE CurrencyID = 0
	GROUP BY 
		StockCompositionID, 
		CompName, 
		CompDescription,	
		StartOfUseGamingDate,
		EndOfUseGamingDate,
		Tag, 
		StockID, 
		StockTypeID,
		Comment	
) eur 
ON	eur.StockCompositionID		= chf.StockCompositionID
AND eur.CompName				= chf.CompName
--AND eur.CompDescription			= chf.CompDescription
--AND eur.StartOfUseGamingDate	= chf.StartOfUseGamingDate
--AND eur.EndOfUseGamingDate		= chf.EndOfUseGamingDate
--AND eur.Tag						= chf.Tag
AND eur.StockID					= chf.StockID
--AND eur.StockTypeID				= chf.StockTypeID
AND eur.Comment 				= chf.Comment
GO
