SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Accounting].[vw_DailyTroncTavoli]
with schemabinding
as
SELECT [GamingDate]
      ,isnull(sum(ValueSfr),0) as TotalTronc
      ,min([ConteggioTimeLoc]) as [ConteggioTimeLoc]
  FROM [Accounting].[vw_AllConteggiDenominations]
  where SnapshotTypeID = 8 --conteggio tronc tavoli
  group by  [GamingDate]






GO
