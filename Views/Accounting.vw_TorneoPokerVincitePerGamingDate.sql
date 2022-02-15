SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_TorneoPokerVincitePerGamingDate]
AS
SELECT COUNT([PK_MovID]) AS Quantita
	,m.MoveType
      ,SUM([AmountEUR]  )  AS [AmountEUR]  
      ,SUM([TaxEUR]		)  AS [TaxEUR]		
      ,SUM([BuyInEUR]	)  AS [BuyInEUR]	
      ,SUM([AmountCHF]  )  AS [AmountCHF]  
      ,SUM([TaxCHF]		)  AS [TaxCHF]		
      ,SUM([BuyInCHF]	)  AS [BuyInCHF]	
      ,[PK_TPGiornataID]
      ,[GiornoName]
      ,[DisplayName]
      ,m.[GamingDate]
      ,[TorneoName]
	  ,m.PK_TorneoID
      ,[DayType]
  FROM [Snoopy].[vw_TorneoPokerCashMov] m
  WHERE MoveType IN(1,2)
  GROUP BY 
      [PK_TPGiornataID]
		,m.MoveType
      ,[GiornoName]
      ,[DisplayName]
      ,m.[GamingDate]
	  ,m.PK_TorneoID
      ,[TorneoName]
      ,[DayType]


GO
