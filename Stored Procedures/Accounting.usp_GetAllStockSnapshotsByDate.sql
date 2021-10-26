SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_GetAllStockSnapshotsByDate]
@ssTypeID int,
@GamingDate smalldatetime,
@StockTypeID int,
@StockID int
AS
	--if we do not specify a StockID check the StockTypeID
	if (@StockID IS NULL AND (@StockTypeID is null or @StockTypeID not in (select StockTypeID from CasinoLayout.StockTypes)))
	begin
		raiserror('Must specify a valid StockTypeID',16,-1)
		return (1)
	end
	if (@GamingDate is null)
	begin
		--get current gaming date for the specified stock type
		set @GamingDate = 
			GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				@StockTypeID)
	end
	if (@StockID is NOT null and NOT exists 
		(
			select StockID from CasinoLayout.Stocks WHERE StockID = @StockID 
			 )
			)
	begin
		raiserror('Invalid StockID %d specified' ,16,-1,@StockID)
		return (1)
	end


	if (@ssTypeID is null) or (@ssTypeID not in (select SnapshotTypeID from CasinoLayout.SnapshotTypes))
	begin
		raiserror('Must specify a valid Snapshot type ID',16,-1)
		return (1)
	end
	--print 'Gaming date form user function is dbo.GetGamingLocalDate '+ convert(nvarchar,@GamingDate,113)
	if (@StockID is null)
		select  
			LifeCycleSnapshotID,
			SnapshotTypeID,
			FName,
			LifeCycleID, 
			StockID, 
			Tag, 
			StockTypeID, 
			MinBet, 
			SnapshotTimeLoc, 
			SnapshotTimeUTC,
			GamingDate,
			UserAccessID,
			OwnerUserID,
			OwnerName,
			ComputerName,
		        LoginDateLoc,
			LogoutDateLoc,
			OwnerUserGroupID,
			ConfirUserID,
			ConfirName,
			ConfirUserGroupID, 
			IsToday,
			IsStockOpen,
			TotalCHF       
		from Accounting.vw_AllSnapshots
			where GamingDate = @GamingDate 
			and SnapshotTypeID = @ssTypeID 
			and StockTypeID = @StockTypeID
			order by StockID
	else
		select  
			LifeCycleSnapshotID,
			SnapshotTypeID,
			FName,
			LifeCycleID, 
			StockID, 
			Tag, 
			StockTypeID, 
			MinBet, 
			SnapshotTimeLoc, 
			SnapshotTimeUTC, 
			GamingDate,
			UserAccessID,
			OwnerUserID,
			OwnerName,
			ComputerName,
		        LoginDateLoc,
			LogoutDateLoc,
			OwnerUserGroupID,
			ConfirUserID,
			ConfirName,
			ConfirUserGroupID, 
			IsToday,
			IsStockOpen,
			TotalCHF       			
		from Accounting.vw_AllSnapshots
			where GamingDate = @GamingDate 
			and SnapshotTypeID = @ssTypeID 
			and StockID = @StockID
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllStockSnapshotsByDate] TO [SolaLetturaNoDanni]
GO
