SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_CreateSnapShotXML] 
@LifeCycleID		int,
@UserAccessID		int,
@ConfUserID			INT,
@ConfUserGroupID	int,
@SSTypeID			INT,
@values				varchar(max),
@SnapshotID			INT output,
@SnapshotTimeLoc	datetime output,
@SnapshotTimeUTC	datetime output
AS

if @LifeCycleID is null and @SnapshotID = 1 --'Apertura'
begin
	raiserror('Use stored procedure usp_OpenLifeCycle to open a new lifecycle',16,1)
	return 1
END

if (@ConfUserID is not null and @ConfUserGroupID is not null )
begin
	if not exists (select UserID from CasinoLayout.Users where UserID = @ConfUserID) 
		or not exists (select UserGroupID from CasinoLayout.UserGroups where UserGroupID = @ConfUserGroupID) 
	begin
		raiserror('Invalid confirmation user id specified',16,1)
		return 4
	end
end



/*
declare @t as varchar(max)
set @t = '<ROOT>
<DENO denoid="1" qty="10.9999" exrate="1.58"/>
<DENO denoid="2" qty="4" exrate="1.58"/>
<DENO denoid="3" qty="123" exrate="1.58"/>
</ROOT>'
declare @XML xml = @t
select 
T.N.value('@denoid', 'int') as DenoID,
cast(T.N.value('@qty', 'float') as int) as qty,
T.N.value('@exrate', 'float') as exrate,
cast(T.N.value('@qty', 'float') as int)* T.N.value('@exrate', 'float') as value
from @XML.nodes('ROOT/DENO') as T(N)
*/

set @SnapshotTimeUTC = GetUTCDate()
set @SnapshotTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@SnapshotTimeUTC)

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateSnapshot

BEGIN TRY  

	insert into Accounting.tbl_Snapshots
		(LifeCycleID,UserAccessID,SnapshotTypeID,SnapshotTime,SnapshotTimeLoc)
	VALUES(@LifeCycleID,@UserAccessID,@SSTypeID,@SnapshotTimeUTC,@SnapshotTimeLoc)

	set @SnapshotID = @@IDENTITY --SCOPE_IDENTITY()

	--if a valid confirmation is specified insert an entry into confirmation table
	if (@ConfUserID is not null and @ConfUserGroupID is not null )
	begin
		if exists (select UserID from CasinoLayout.Users where UserID = @ConfUserID) 
		   and exists (select UserGroupID from CasinoLayout.UserGroups where UserGroupID = @ConfUserGroupID) 
		begin
			insert into Accounting.tbl_Snapshot_Confirmations 
				(LifeCycleSnapshotID,UserID,UserGroupID) 
				VALUES (@SnapshotID,@ConfUserID,@ConfUserGroupID)
		end
	end

	IF @values is NOT NULL AND LEN(@values) > 0
	begin
		declare @XML xml = @values
/*
		select 
		T.N.value('@denoid', 'int') as DenoID,
		cast(T.N.value('@qty', 'float') as int) as qty,
		T.N.value('@exrate', 'float') as exrate
		from @XML.nodes('ROOT/DENO') as T(N)
*/

		--	print 'inserting snapshot value'
		insert into Accounting.tbl_SnapshotValues
		( LifeCycleSnapshotID ,
			DenoID ,
			Quantity ,
			ExchangeRate
		)
		select 
		@SnapshotID ,
		T.N.value('@denoid', 'int'),
		cast(T.N.value('@qty', 'float') as int),
		T.N.value('@exrate', 'float')
		from @XML.nodes('ROOT/DENO') as T(N)
	END



	--in case of Chiusura
	if @SSTypeID = 3
	begin
		DECLARE @Tag VARCHAR(16)
		declare @StockTypeID int

		select @Tag=s.Tag,@StockTypeID=s.StockTypeID
		from CasinoLayout.Stocks s
		inner join Accounting.tbl_LifeCycles lf on lf.StockID = s.StockID
		where lf.LifeCycleID = @LifeCycleID


		--in case closing a live game table
		IF @StockTypeID = 1 --LEFT(@Tag,2) = 'AR'  
		BEGIN
			DECLARE @retMsg NVARCHAR(4000),@table NVARCHAR(4000)

			--clear also table results
			SELECT @retMsg = [GeneralPurpose].[fn_ClearTableResultsOnCISDisplay] (@Tag)


			SELECT @retMsg = [GeneralPurpose].[fn_CloseTableOnCISDisplay] (@Tag)
		END
	END

	COMMIT TRANSACTION trn_CreateSnapshot

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateSnapshot		
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
