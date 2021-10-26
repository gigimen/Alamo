SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_GetLifeCycleCloseDenominations]
@LifeCycleID int
AS
if (@LifeCycleID is null) or 
	(@LifeCycleID < 0) or
	(not exists(select LifeCycleID from Accounting.tbl_LifeCycles where  LifeCycleID = @LifeCycleID))
begin
	raiserror('Must specify a valid LifeCycleID',16,-1)
	return (1)
end
declare @LCSSID int
select @LCSSID = LifeCycleSnapshotID from Accounting.tbl_Snapshots 
	where LifeCycleID = @LifeCycleID
	AND Accounting.tbl_Snapshots.SnapshotTypeID in 
	(
		select SnapshotTypeID from CasinoLayout.SnapshotTypes where FName = 'Chiusura' 
	)
	--snapshot has not been cancelled
	AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
if (@LCSSID is null) 
begin
	raiserror('There is no chiusura snapshot for this LifeCycleID',16,-1)
	return (1)
end

SELECT [LifeCycleSnapshotID]
      ,[SnapshotTypeID]
      ,[FName]
      ,[LifeCycleID]
      ,[StockID]
      ,[GamingDate]
      ,[Tag]
      ,[StockTypeID]
      ,[MinBet]
      ,[SnapshotTimeUTC]
      ,[SnapshotTimeLoc]
      ,[ConfirUserID]
      ,[ConfirUserGroupID]
      ,[OwnerUserID]
      ,[OwnerUserGroupID]
      ,[ValueTypeName]
      ,[FDescription]
      ,[IsFisical]
      ,[DenoID]
      ,[ValueTypeID]
      ,[Denomination]
      ,[Quantity]
      ,[ExchangeRate]
      ,[InitialQty]
      ,[WeightInTotal]
      ,[IsToday]
      ,[IsStockOpen]
FROM [Accounting].[vw_AllSnapshotDenominations]
where LifeCycleSnapshotID = @LCSSID

GO
GRANT EXECUTE ON  [Accounting].[usp_GetLifeCycleCloseDenominations] TO [SolaLetturaNoDanni]
GO
