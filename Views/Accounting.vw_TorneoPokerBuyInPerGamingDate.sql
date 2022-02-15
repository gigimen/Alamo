SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Accounting].[vw_TorneoPokerBuyInPerGamingDate]
AS
SELECT COUNT([PK_MovID]) AS Quantita
      ,SUM([AmountEUR]  ) AS [AmountEUR]  
      ,SUM([TaxEUR]		) AS [TaxEUR]	  
      ,SUM([BuyInEUR]	) AS [BuyInEUR]	  
      ,SUM([AmountCHF]  ) AS [AmountCHF]  
      ,SUM([TaxCHF]		) AS [TaxCHF]	  
      ,SUM([BuyInCHF]	) AS [BuyInCHF]	  
      ,[PK_TPGiornataID]
      ,[GiornoName]
      ,[DisplayName]
      ,m.[GamingDate]
      ,[TorneoName]
	  ,m.PK_TorneoID
      ,[m].[PK_DayTypeID]
      ,[DayType]
  FROM [Snoopy].[vw_TorneoPokerCashMov] m
  WHERE MoveType = 0-- IN(1,2)
  GROUP BY 
		[PK_TPGiornataID]
      ,[GiornoName]
      ,[DisplayName]
      ,m.[GamingDate]
      ,[TorneoName]
	  ,m.PK_TorneoID
      ,[m].[PK_DayTypeID]
      ,[DayType]


GO
