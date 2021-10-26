SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE procedure [Accounting].[usp_GetLastSnapshotsValues] 
@StockID 	INT,@ValueTypeID INT
AS

if @StockID is null or not exists (select StockID from CasinoLayout.Stocks where StockID = @StockID)
begin
	raiserror('Invalid Stock id',16,1)
	return (1)
end

/*


DECLARE @StockID 	INT,@ValueTypeID INT
SET @ValueTypeID = 21
set @StockID 	= 46

execute [Accounting].[usp_GetLastSnapshotsValues]  @StockID,@ValueTypeID
--*/

declare @LastSnapshotTime 	DATETIME,@LastGamingDate DATETIME

select @LastGamingDate = max(GamingDate)  from Accounting.vw_AllStockLifeCycles where stockid = @StockID

--select @LastGamingDate
--get the latest snapshot which is not an apertura 
--and has not been canceled
IF @ValueTypeID IS NULL
begin
	SELECT  @LastSnapshotTime = MAX(SnapshotTime) 
	FROM  Accounting.tbl_LifeCycles lc
		INNER JOIN Accounting.tbl_Snapshots  ss
		ON lc.LifeCycleID = ss.LifeCycleID 
	where 	lc.StockID = @StockID
		and lc.GamingDate <= @LastGamingDate
		and ss.LCSnapShotCancelID is null
		AND ss.SnapshotTypeID NOT IN (1,6) --not an apertura o conteggio uscita
                          
	if @LastSnapshotTime is null
	begin
		raiserror('Stock %d never opened',16,1,@StockID)
		return (1)
	END
END
ELSE
BEGIN
	SELECT  @LastSnapshotTime = MAX(SnapshotTimeUTC) 
	FROM  Accounting.vw_AllSnapshotDenominations  
	where 	StockID = @StockID
		and GamingDate <= @LastGamingDate
		AND SnapshotTypeID  NOT IN (1,6) --not an apertura o conteggio uscita
         AND ValueTypeID =   @ValueTypeID               
	if @LastSnapshotTime is null
	begin
		raiserror('Stock %d never used that valuetype',16,1,@StockID)
		return (1)
	END


END

--select @LastSnapshotTime


IF @ValueTypeID IS null
	SELECT [LifeCycleSnapshotID]
		  ,[SnapshotTypeID]
		  ,[FName]
		  ,[LifeCycleID]
		  ,[StockID]
		  ,t.[GamingDate]
		  ,[Tag]
		  ,[StockTypeID]
		  ,[MinBet]
		  ,[SnapshotTimeUTC]
		  ,[SnapshotTimeLoc]
		  ,[ConfirUserID]
		  ,[ConfirUserGroupID]
		  ,[OwnerUserID]
		  ,[OwnerUserGroupID]
		  ,t.[ValueTypeName]
		  ,t.[FDescription]
		  ,t.[IsFisical]
		  ,t.[DenoID]
		  ,t.[ValueTypeID]
		  ,t.CurrencyID
		  ,[Denomination]
		  ,[Quantity]
		  ,[ExchangeRate]
		  ,[InitialQty]
		  ,[WeightInTotal]
		  ,[IsToday]
		  ,[IsStockOpen],
			r.IntRate AS euroRate     
		from Accounting.vw_AllSnapshotDenominations t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.GamingDate AND r.CurrencyID = 0
		where t.StockID = @StockID
		--and t.GamingDate = @LastGamingDate
		and t.SnapshotTimeUTC = @LastSnapshotTime
ELSE
	SELECT [LifeCycleSnapshotID]
		  ,[SnapshotTypeID]
		  ,[FName]
		  ,[LifeCycleID]
		  ,[StockID]
		  ,t.[GamingDate]
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
		  ,t.CurrencyID
		  ,[Denomination]
		  ,[Quantity]
		  ,[ExchangeRate]
		  ,[InitialQty]
		  ,[WeightInTotal]
		  ,[IsToday]
		  ,[IsStockOpen],
			r.IntRate AS euroRate     
		from Accounting.vw_AllSnapshotDenominations t
		LEFT OUTER JOIN Accounting.tbl_CurrencyGamingdateRates r ON r.GamingDate = t.GamingDate AND r.CurrencyID = 0
		where StockID = @StockID
		--and t.GamingDate = @LastGamingDate
		and SnapshotTimeUTC = @LastSnapshotTime
		AND [ValueTypeID] = @ValueTypeID
GO
