SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [CasinoLayout].[vw_VariazioniInitialStock]
AS
  SELECT [StockCompositionID]
      ,[CompName]
      ,[CompDescription]
      ,[StartOfUseGamingDate]
      ,[EndOfUseGamingDate]
      ,[Tag]
      ,[StockID]
      ,[StockTypeId]
      ,[Comment]
      ,[CreationDate]
      ,[TotaleCHF]
	  ,a.PrecTotaleCHF
      ,[TotaleCHF] - a.PrecTotaleCHF AS IncrementoCHF
      ,[DenocCountCHF]
      ,[TotaleEUR]
	  ,a.PrecTotaleEUR
	  ,[TotaleEUR] - a.PrecTotaleEUR AS IncrementoEUR
      ,[DenoCountEUR]
FROM
(


	SELECT [StockCompositionID]
		  ,[CompName]
		  ,[CompDescription]
		  ,[StartOfUseGamingDate]
		  ,[EndOfUseGamingDate]
		  ,[Tag]
		  ,[StockID]
		  ,[StockTypeId]
		  ,[Comment]
		  ,[CreationDate]
		  ,[TotaleCHF]
		  ,[DenocCountCHF]
		  ,[TotaleEUR]
		  ,[DenoCountEUR]
		  ,LAG(i.TotaleCHF,1,0) OVER(PARTITION BY StockID ORDER BY StartOfUseGamingDate ASC) AS PrecTotaleCHF
		  ,LAG(i.TotaleEUR,1,0) OVER(PARTITION BY StockID ORDER BY StartOfUseGamingDate ASC) AS PrecTotaleEUR

	FROM [CasinoLayout].[vw_AllStockCompositionTotalsByCurrency] i
) a
GO
