SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_TorneoPokerSatelliteBSE]
AS
SELECT 
		   a.[Quantita]
		  ,a.[AmountEUR]
		  ,a.[TaxEUR]
		  ,a.[BuyInEUR]
		  ,a.[AmountCHF]
		  ,a.[TaxCHF]
		  ,a.[BuyInCHF]
		  ,a.[PK_TPGiornataID]
		  ,a.[GiornoName]
		  ,a.[DisplayName]
		  ,a.[GamingDate]
		  ,a.[TorneoName]
		  ,a.[PK_TorneoID]
		  ,a.[DayType]
		  ,a.RottoEUR
		  ,a.RottoCHF
		  ,a.Vinti 
		  ,a.FinalTaxEUR
		  ,a.FinalTaxEUR * cr.IntRate														AS FinalTaxCHF
		  ,a.FinalBuyInEUR
		  ,a.FinalBuyInEUR * cr.IntRate														AS FinalBuyInCHF
		  ,a.FinalAmountEUR
		  ,a.FinalAmountEUR * cr.IntRate													AS FinalAmountCHF
		  ,a.Vinti * a.FinalAmountEUR														AS VintiAmountEUR
		  ,a.Vinti * a.FinalAmountEUR * cr.IntRate											AS VintiAmountCHF
		  ,a.RottoEUR  + (a.Vinti * a.FinalAmountEUR)										AS CashOutEUR
		  ,a.RottoCHF  + (a.Vinti * a.FinalAmountEUR * cr.IntRate)							AS CashOutCHF
		  ,a.[AmountEUR]																	AS CashInEUR
		  ,a.[AmountCHF]																	AS CashInCHF
		  ,a.[AmountEUR] - (a.RottoEUR  + (a.Vinti * a.FinalAmountEUR ))					AS BSEEUR
		  ,a.[AmountCHF] - (a.RottoCHF  + (a.Vinti * a.FinalAmountEUR * cr.IntRate))		AS BSECHF

FROM
(
	SELECT 
		   m.[Quantita]
		  ,m.[AmountEUR]
		  ,m.[TaxEUR]
		  ,m.[BuyInEUR]
		  ,m.[AmountCHF]
		  ,m.[TaxCHF]
		  ,m.[BuyInCHF]
		  ,g.[PK_TPGiornataID]
		  ,m.[GiornoName]
		  ,m.[DisplayName]
		  ,g.[GamingDate]
		  ,m.[TorneoName]
		  ,m.[PK_TorneoID]
		  ,m.[DayType]
		  ,ISNULL(v.[AmountEUR],0) AS RottoEUR
		  ,ISNULL(v.AmountCHF,0) AS RottoCHF
		  ,FLOOR((m.[BuyInEUR] )/ (f.FinalTaxEUR + f.FinalBuyInEUR)) AS Vinti 
		  ,f.FinalTaxEUR
		  ,f.FinalBuyInEUR
		  ,f.FinalTaxEUR + f.FinalBuyInEUR AS FinalAmountEUR
	FROM [Accounting].[vw_TorneoPokerBuyInPerGamingDate] m
		INNER JOIN [CasinoLayout].[tbl_TorneiPokerGiornate] g ON g.PK_TPGiornataID = m.[PK_TPGiornataID]
		INNER JOIN 
		(
		  SELECT 
		  FK_TorneoID,
		  CAST(MAX(TaxCents) AS FLOAT) / 100.00			AS FinalTaxEUR ,
		  CAST(MAX(BuyInCents) AS FLOAT) / 100.00		AS FinalBuyInEUR 
		  FROM [CasinoLayout].[tbl_TorneiPokerGiornate]
		  WHERE FK_DayTypeID = 2
		  GROUP BY FK_TorneoID
		) f ON f.FK_TorneoID = g.FK_TorneoID
		LEFT OUTER JOIN [Accounting].[vw_TorneoPokerVincitePerGamingDate] v ON v.[PK_TPGiornataID] = m.[PK_TPGiornataID] AND v.MoveType = 1
	WHERE PK_DayTypeID = 1
) a
INNER JOIN Accounting.tbl_CurrencyGamingdateRates cr ON cr.GamingDate = a.GamingDate AND cr.CurrencyID = 0
GO
