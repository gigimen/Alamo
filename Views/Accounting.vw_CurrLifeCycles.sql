SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE  VIEW [Accounting].[vw_CurrLifeCycles]
WITH SCHEMABINDING
AS
SELECT [LifeCycleID]
      ,[StockID]
      ,[StockCompositionID]
      ,[Tag]
      ,[StockTypeID]
      ,[KioskID]
      ,[CloseTimeUTC]
      ,[CloseTime]
      ,[CloseSnapshotID]
      ,[OpenTimeUTC]
      ,[OpenTime]
      ,[AperturaSnapshotID]
      ,[GamingDate]
      ,[UserAccessID]
      ,[SiteName]
      ,[ApplicationName]
      ,[OwnerUserID]
      ,[OwnerName]
      ,[loginName]
      ,[OwnerUserGroupID]
      ,[ConfirUserID]
      ,[ConfirName]
      ,[ConfirUserGroupID]
  FROM [Accounting].[vw_AllStockLifeCycles]
  WHERE GamingDate =	(SELECT MAX(GamingDate) FROM Accounting.tbl_LifeCycles)
GO
