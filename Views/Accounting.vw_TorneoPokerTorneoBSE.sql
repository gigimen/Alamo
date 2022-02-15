SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_TorneoPokerTorneoBSE]
AS
SELECT 
			v.LastDay
		  ,a.[TorneoName]
		  ,a.[PK_TorneoID]
		  ,a.[Quantita]		
		  ,a.[AmountEUR]
		  ,a.[TaxEUR]
		  ,a.[BuyInEUR]
		  ,a.[AmountCHF]
		  ,a.[TaxCHF]
		  ,a.[BuyInCHF]
		  ,s.Vinti AS VincitoriSatellite
		  ,s.Vinti * s.[FinalAmountEUR] AS SatAmountEUR
		  ,s.Vinti * s.[FinalAmountCHF] AS SatAmountCHF

		  ,a.Quantita + s.Vinti			AS Partecipanti
		  ,a.[AmountEUR] + (s.Vinti * s.[FinalAmountEUR]) 	AS CashInEUR 
		  ,a.[AmountCHF] + (s.Vinti * s.[FinalAmountCHF]) 	AS CashInCHF 
		  ,v.AmountEUR	 										AS CashOutEUR
		  ,v.AmountCHF	 										AS CashOutCHF
		  ,a.[AmountEUR] + (s.Vinti * s.[FinalAmountEUR]) 	-
			v.AmountEUR	 										AS BSEEUR
		  ,a.[AmountCHF] + (s.Vinti * s.[FinalAmountCHF]) -
		    v.AmountCHF										 AS BSECHF

from
(
	SELECT 
		   SUM(m.[Quantita]		) as [Quantita]		
		  ,SUM(m.[AmountEUR]	) as [AmountEUR]	
		  ,SUM(m.[TaxEUR]		) as [TaxEUR]		
		  ,SUM(m.[BuyInEUR]		) as [BuyInEUR]		
		  ,SUM(m.[AmountCHF]	) as [AmountCHF]	
		  ,SUM(m.[TaxCHF]		) as [TaxCHF]		
		  ,SUM(m.[BuyInCHF]		) as [BuyInCHF]		
		  ,m.[TorneoName]
		  ,m.[PK_TorneoID]
	FROM [Accounting].[vw_TorneoPokerBuyInPerGamingDate] m
	WHERE m.PK_DayTypeID = 2
	group BY
    		m.[TorneoName]
		  ,m.[PK_TorneoID]

) a
INNER JOIN 
(
	SELECT 
	PK_TorneoID,
	SUM(AmountEUR) AS AmountEUR,
	SUM(AmountCHF) AS AmountCHF,
	MAX([GamingDate]) AS LastDay
	FROM [Accounting].[vw_TorneoPokerVincitePerGamingDate] 
	WHERE MoveType = 2
	GROUP by PK_TorneoID
) v ON v.PK_TorneoID = a.PK_TorneoID
LEFT OUTER JOIN 
(
	SELECT 
			   SUM(m.[Vinti]		) as [Vinti]		
			  ,SUM(m.[Quantita]		) as [Quantita]		
			  ,SUM(m.[VintiAmountEUR]	) as VintiAmountEUR	
			  ,SUM(m.[VintiAmountCHF]	) as VintiAmountCHF	
			  ,SUM(m.[AmountEUR]	) as [AmountEUR]	
			  ,SUM(m.[TaxEUR]		) as [TaxEUR]		
			  ,SUM(m.[BuyInEUR]		) as [BuyInEUR]		
			  ,SUM(m.[AmountCHF]	) as [AmountCHF]	
			  ,SUM(m.[TaxCHF]		) as [TaxCHF]		
			  ,SUM(m.[BuyInCHF]		) as [BuyInCHF]		
			  ,m.[TorneoName]
			  ,m.[PK_TorneoID]
			  ,MAX([FinalAmountEUR])	AS [FinalAmountEUR]
			  ,MAX([FinalAmountCHF])	AS [FinalAmountCHF]
	FROM [Accounting].[vw_TorneoPokerSatelliteBSE] m 
		group BY
    			m.[TorneoName]
			  ,m.[PK_TorneoID]
) s
ON s.[PK_TorneoID] = a.[PK_TorneoID]
GO
