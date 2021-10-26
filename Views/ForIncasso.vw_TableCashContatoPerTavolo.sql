SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [ForIncasso].[vw_TableCashContatoPerTavolo]
WITH SCHEMABINDING
AS
/*
select * from [ForIncasso].[vw_TableCashContatoPerTavolo]
where GamingDate = '5.24.2019'

*/
SELECT [GamingDate]
      ,[StockID]
      ,[Tag]
	  ,CurrencyID
	  ,Acronim
      ,SUM([Value]) AS Value
      ,MIN([ConteggioTimeLoc]) AS [ConteggioTimeLoc]
  FROM [ForIncasso].[vw_AllConteggiSummary]
  WHERE SnapshotTypeID = 7 --conteggio cash box tavoli
  GROUP BY  [GamingDate]
      ,[StockID]
      ,[Tag]
	  ,CurrencyID
	  ,Acronim
GO
