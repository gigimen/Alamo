SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [CasinoLayout].[usp_GetTotalStock] 
@GamingDate datetime,
@totStock float output
AS
/*
DECLARE
@GamingDate datetime,
@totStock float 

SET @GamingDate = '2.10.2015'
*/
	SELECT scs.[StockCompositionID]
		,sc.FName AS [CompName]
		,sc.FDescription AS [CompDescription]
		,st.[Tag]
		,st.[StockID]
		,st.[StockTypeId]
		,scs.StartOfUseGamingDate
		,scs.EndOfUseGamingDate
		,ISNULL(SUM(scd.InitialQty*den.Denomination),0) AS Totale
	FROM CasinoLayout.[tbl_StockComposition_Stocks] scs
	INNER JOIN CasinoLayout.Stocks st ON st.StockID = scs.StockID
	INNER JOIN CasinoLayout.StockCompositions sc ON sc.StockCompositionID = scs.StockCompositionID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = scs.StockCompositionID
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = scd.DenoID
	where st.stocktypeid in(2,4,6,7) 
	AND scs.StartOfUseGamingDate <= @GamingDate
	and (scs.EndOfUseGamingDate is null or @GamingDate <= scs.EndOfUseGamingDate )
	GROUP BY scs.[StockCompositionID]
		,sc.FName 
		,sc.FDescription
		,st.[Tag]
		,st.[StockID]
		,st.[StockTypeId]
		,scs.StartOfUseGamingDate
		,scs.EndOfUseGamingDate
	ORDER BY st.StockID

	select @totStock = ISNULL(SUM(scd.InitialQty*den.Denomination),0) 
	FROM CasinoLayout.[tbl_StockComposition_Stocks] scs
	INNER JOIN CasinoLayout.Stocks st ON st.StockID = scs.StockID
	INNER JOIN CasinoLayout.StockCompositions sc ON sc.StockCompositionID = scs.StockCompositionID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations scd ON scd.StockCompositionID = scs.StockCompositionID
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = scd.DenoID
	where st.stocktypeid in(2,4,6,7) 
	AND scs.StartOfUseGamingDate <= @GamingDate
	and (scs.EndOfUseGamingDate is null or @GamingDate <= scs.EndOfUseGamingDate )


select @totStock as '@totStock'


GO
