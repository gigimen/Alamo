SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_TableCashContato]
WITH SCHEMABINDING
AS

SELECT [GamingDate]
      ,[StockID]
      ,[Tag]
      ,sum([ValueSfr]) as TotSfr
      ,min([ConteggioTimeLoc]) as [ConteggioTimeLoc]
  FROM [Accounting].[vw_AllConteggiDenominations]
  where SnapshotTypeID = 7 --conteggio cash box tavoli
  group by  [GamingDate]
      ,[StockID]
      ,[Tag]






GO
