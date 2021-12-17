SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [ForIncasso].[vw_DailyGettoniCasse]
AS
SELECT [GamingDate]
      ,[CurrencyID]
	  ,ValueTypeID
      ,[CurrencyAcronim]
      ,SUM(ISNULL([Chiusura],0) * Denomination) AS Chiusura 
      ,SUM(ISNULL([InitialQty],0) * Denomination) AS Apertura
  FROM [Accounting].[vw_AllChiusuraConsegnaDenominations]
  WHERE StockTypeID IN(4,7) AND ValueTypeID IN(1,36,42,59) --gettoni chf,gioco euro, euro e poker
  --AND GamingDate = '7.14.2019'
  GROUP BY
  [GamingDate]
      ,[CurrencyID]
      ,ValueTypeID
      ,[CurrencyAcronim]
GO
