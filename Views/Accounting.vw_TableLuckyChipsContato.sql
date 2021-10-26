SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_TableLuckyChipsContato]
with schemabinding
as
SELECT [GamingDate]
      ,[StockID]
      ,[Tag]
      ,sum(Quantity) as TotCount
      ,min([ConteggioTimeLoc]) as [ConteggioTimeLoc]
  FROM [Accounting].[vw_AllConteggiDenominations]
  where SnapshotTypeID = 7 --conteggio cash box tavoli
  and DenoID = 78
  group by  [GamingDate]
      ,[StockID]
      ,[Tag]








GO
