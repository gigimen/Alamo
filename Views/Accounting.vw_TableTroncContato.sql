SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_TableTroncContato]
WITH SCHEMABINDING
AS
SELECT [GamingDate]
      ,[StockID]
      ,[Tag]
	  ,ConteggioID
      ,SUM([ValueSfr]) AS TotSfr
      ,MIN([ConteggioTimeLoc]) AS [ConteggioTimeLoc]
  FROM [Accounting].[vw_AllConteggiDenominations]
  WHERE SnapshotTypeID = 8 --conteggio tronc box tavoli
  GROUP BY  [GamingDate]
      ,[StockID]
	  ,ConteggioID
      ,[Tag]







GO
