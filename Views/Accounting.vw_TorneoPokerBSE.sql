SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_TorneoPokerBSE]
AS
SELECT co.PK_TorneoID
	  ,co.TorneoName
	  ,co.CashoutEUR
	  ,co.LastDay
	  ,co.CashoutCHF
	  ,ci.CashInEUR
	  ,ci.CashInCHF
	  ,ci.TaxEUR
	  ,ci.BuyInEUR
	  ,ci.CashInEUR - co.CashoutEUR AS BSEEUR
	  ,ci.CashInCHF - co.CashoutCHF AS BSECHF
FROM 
(
SELECT SUM([AmountEUR]) AS CashoutEUR
      ,MAX([GamingDate]) AS LastDay
      ,SUM([AmountCHF]) AS CashoutCHF
	  ,PK_TorneoID
	  ,TorneoName
  FROM [Accounting].[vw_TorneoPokerVincitePerGamingDate]
  GROUP BY PK_TorneoID
	  ,TorneoName

) co
INNER JOIN 
(
 
SELECT SUM([AmountEUR]) AS CashInEUR
      ,SUM([TaxEUR]) AS TaxEUR
      ,SUM([BuyInEUR]) AS BuyInEUR
      ,SUM([AmountCHF]) AS CashInCHF
	  ,[PK_TorneoID]
  FROM [Alamo].[Accounting].[vw_TorneoPokerBuyInPerGamingDate]
  GROUP BY [PK_TorneoID]
  ) ci ON ci.[PK_TorneoID] = co.[PK_TorneoID]
GO
