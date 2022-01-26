SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [FloorActivity].[usp_CheckUserOwnsSomeStockToday] 
@StockTypeID int,
@UserID int,
@StockID int output,
@StockTag varchar(50) output,
@LFID int output,
@today datetime output,
@openUTC datetime output,
@openLoc datetime output,
@IsOpen bit output,
@IsToday bit output
AS


--run some checks on input data
if not exists( select StockTypeID from CasinoLayout.StockTypes where StockTypeID = @StockTypeID)
begin
	raiserror('Must specify a valid StockTypeID',16,1)
	return(0)
end
if not exists( select UserID from CasinoLayout.Users where UserID = @UserID)
begin
	raiserror('Must specify a valid UserID',16,1)
	return(0)
END

--GET THE GAMING DATE FOR THAT STOCK TYPE
set @today = GeneralPurpose.fn_GetGamingLocalDate2(
	GetUTCDate(),
	--pass current hour difference between local and utc 
	DATEDIFF (hh , GetUTCDate(),GetDate()),
	@StockTypeID)

PRINT @today

--did the user forgot any stock open yeasterday?
select 	
	@StockID = StockID,
	@LFID = LifeCycleID,
	@StockTag = Tag,
	@openUTC = ApTimeUTC,
	@openLoc = [ApTimeLoc] 
FROM [FloorActivity].[vw_AllLastStockOwners] 
WHERE GamingDate = DATEADD (DAY,-1,@today)
AND ChSnapshotID IS NULL --torlley is still open
AND StockTypeID = @StockTypeID
AND 
--the user was the last change owner or he was th e apertura owner and no chengowner has benn done
(ChUserID = @UserID OR (chuserid IS NULL AND ApUserID = @UserID))

IF @StockID IS NOT NULL
BEGIN
	--we forgot the trolley open yeasterday!!
	SET @IsOpen = 1
	SET @IsToday = 0
	SET @today = DATEADD (DAY,-1,@today)
END
ELSE
BEGIN

	SET @IsToday = 1
	--first check that some change owner snapshot exists today
	--FOR STOCK OF THAT STOCK TYPE
	if exists ( select LifeCycleSnapshotID from Accounting.tbl_Snapshots ss1 
				inner join Accounting.tbl_LifeCycles lf1 on lf1.LifeCycleID = ss1.LifeCycleID 
				inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = lf1.StockID
				where lf1.GamingDate = @today
				and ss1.SnapshotTypeID = 4 --CHANGEOWNER
				and ss1.LCSnapShotCancelID is null
				and CasinoLayout.Stocks.StockTypeID = @StockTypeID
			)
	--then check that the last one is for the SPECIFIED user
	begin
	print 'there was some change owner'
		select 	@StockID = AA.StockID,
			@LFID = ss.LifeCycleID,
			@StockTag = st.Tag,
			@openUTC = ss.SnapshotTime,
			@openLoc = ss.SnapshotTimeLoc
			from Accounting.tbl_Snapshots ss 
			inner join Accounting.tbl_LifeCycles lf on lf.LifeCycleID = ss.LifeCycleID 
			inner join CasinoLayout.Stocks st on st.StockID = lf.StockID
			inner JOIN Accounting.tbl_Snapshot_Confirmations lfc ON lfc.LifeCycleSnapshotID = ss.LifeCycleSnapshotID
			inner join 
				(
				--GET THE LAST CHANGEOWNER FOR ALL Stocks OF THAT STOCK TYPE
				select CasinoLayout.Stocks.StockID,max(SnapshotTime) as SnapshotTime
				from Accounting.tbl_Snapshots ss1 
				inner join Accounting.tbl_LifeCycles lf1 on lf1.LifeCycleID = ss1.LifeCycleID 
				inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = lf1.StockID
				where lf1.GamingDate = @today
				and ss1.SnapshotTypeID = 4 --CHANGEOWNER
				and ss1.LCSnapShotCancelID IS NULL
				and CasinoLayout.Stocks.StockTypeID = @StockTypeID
				group by CasinoLayout.Stocks.StockID	
				) AA 
			on AA.StockID = st.StockID and AA.SnapshotTime = ss.SnapshotTime 
			where  lfc.UserID = @UserID
	end
	--nothing found THEN look for apertura snapshots
	if @StockID is null
	begin
		select  @StockID = st.StockID,
			@LFID = lf.LifeCycleID,
			@StockTag = Tag,
			@openUTC = ss.SnapshotTime,
			@openLoc = ss.SnapshotTimeLoc 
			from Accounting.tbl_Snapshots ss 
			inner join Accounting.tbl_LifeCycles lf on lf.LifeCycleID = ss.LifeCycleID 
			inner join CasinoLayout.Stocks st on st.StockID = lf.StockID
			inner join FloorActivity.tbl_UserAccesses ua on ua.UserAccessID = ss.UserAccessID
			where lf.GamingDate = @today 
				and ua.UserID = @UserID
				and ss.SnapshotTypeID = 1 --APERTURA
				and ss.LCSnapShotCancelID is null
				and st.StockTypeID = @StockTypeID
		--if the user owned a lifecycle
		if @StockID is not null
		begin
			--make sure that ther is no changeowner for this LifeCycleID
			if exists (
				select LifeCycleSnapshotID from Accounting.tbl_Snapshots ss1 
				inner join Accounting.tbl_LifeCycles lf1 on lf1.LifeCycleID = ss1.LifeCycleID 
				inner join CasinoLayout.Stocks on CasinoLayout.Stocks.StockID = lf1.StockID
				where ss1.LifeCycleID = @LFID 
					and ss1.LCSnapShotCancelID is null	
					and ss1.SnapshotTypeID = 4 -- CHANGEOWNER
					and CasinoLayout.Stocks.StockTypeID = @StockTypeID)
			begin
				print 'was but changed'
				--user opened the life cycle but is no more the owner 
				set @StockID = null
				set @LFID = null
				set @StockTag = null
			end
		end
	end
	--IF ANYTHING FOUND MAKE SURE IT IS NOT CLOSED
	if @LFID is NOT NULL
	begin
		if exists
		(
			SELECT LifeCycleSnapshotID
			FROM    Accounting.tbl_Snapshots 
			WHERE   Accounting.tbl_Snapshots.SnapshotTypeID = 3 --Chiusura
			AND Accounting.tbl_Snapshots.LifeCycleID = @LFID
			--snapshot has not been cancelled
			AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
		)
	--	print 'Chiusura snapshot does exists'
		--if Chiusura snapshot does exists the stock is closed
			set @IsOpen = 0
		else
			set @IsOpen = 1
	end
	else
		set @IsOpen = null
end
GO
