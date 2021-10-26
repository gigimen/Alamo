SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_DailyMovimentoGettoniGiocoEuro]
AS
	--euro convertiti a franchi: redem - acq gettoni gioco euro
SELECT [LifeCycleID]
      ,SUM(
		CASE WHEN [DenoID] = 183 --acquisto gettoni gioco euro: escono CHF entrano EUR
		THEN -[TotEuro] --escono euro entrano gettoni chf
		ELSE [TotEuro] 
		END 
		) AS EURToGettoni
      ,SUM(
		CASE WHEN [DenoID] = 183 --acquisto gettoni gioco euro: escono CHF entrano EUR
		THEN [TotGettoni] 
		ELSE -[TotGettoni] 
		END ) AS GettoniToEUR
  FROM [Accounting].[vw_AllMovimentiGettoniGiocoEuro]
  GROUP BY LifeCycleID

GO
