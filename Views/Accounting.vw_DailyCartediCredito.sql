SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_DailyCartediCredito] 
AS
SELECT [LifeCycleID]
		,DenoID
      ,[GamingDate]
      ,COUNT( DISTINCT [CreditCardTransID]) AS cCount
      ,SUM([EuroAtTerminal]) AS [EuroAtTerminal]
      ,SUM([EuroNetti]) AS EuroNetti
      ,SUM([CHF]) AS CHF
      ,SUM([CommissioneEuro]) AS CommissioniEuro
  FROM [Snoopy].[vw_AllCartediCreditoEx]
  GROUP BY [LifeCycleID]
		,DenoID
      ,[GamingDate]

GO
