SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_CreateChiusuraTableXMLEx]
@LifeCycleID		int,
@UserID int,
@SiteID int,
@UserGroupID int,
@AppID INT,
@ConfUserID int,
@ConfUserGroupID int,
@values				varchar(max),
@CreateConsegna		bit,
@SnapshotID			INT output,
@SnapshotTimeLoc	datetime output,
@SnapshotTimeUTC	datetime output
AS

if @LifeCycleID is null 
begin
	raiserror('Invalid lifecycle specified',16,1)
	return 1
END

IF @values is NULL OR LEN(@values) = 0
begin
	raiserror('Must specify Chiusura values',16,1)
	return 1
end

declare @ret int
set @ret = 0
declare @UserAccessID int

--first create user access

EXECUTE @ret = [FloorActivity].[usp_CreateUserAccess] 
   @SiteID
  ,@UserID
  ,@UserGroupID
  ,@AppID
  ,@UserAccessID OUTPUT
IF @ret <> 0 RETURN @ret



/*
ESEMPIO DI CREAZIONE DELLA Consegna

declare @LifeCycleID int

set @LifeCycleID = 160363

declare @t as varchar(max)
set @t = '<ROOT><DENO denoid="1" exrate="1.000000" qty="3" /><DENO denoid="2" exrate="1.000000" qty="5" /><DENO denoid="3" exrate="1.000000" qty="41" /><DENO denoid="4" exrate="1.000000" qty="148" /><DENO denoid="5" exrate="1.000000" qty="3" /><DENO denoid="6" exrate="1.000000" qty="403" /><DENO denoid="7" exrate="1.000000" qty="26" /><DENO denoid="8" exrate="1.000000" qty="200" /><DENO denoid="9" exrate="1.000000" qty="155" /><DENO denoid="13" exrate="1.000000" qty="90" /></ROOT>'
declare @XML xml = @t
select 
T.N.value('@denoid', 'int') as DenoID,
T.N.value('@qty', 'int') as Chiusura,
T.N.value('@exrate', 'float') as exrate,
T.N.value('@qty', 'int') * T.N.value('@exrate', 'float') as value
from @XML.nodes('ROOT/DENO') as T(N)


---questo mi da le quantita da inserire in Consegna
select c.DenoID,c.Consegna,c.exrate
from
(
	select DenoID,InitialQty,ModuleValue ,
		T.N.value('@qty', 'int') as Chiusura,
		T.N.value('@exrate', 'float') as exrate,

	[Accounting].[fn_StockCalculateConsegna] (
					[DenoID],
					T.N.value('@qty', 'int'),
					[InitialQty],
					[moduleValue],
					1
		)  as Consegna
	from [CasinoLayout].[vw_AllStockCompositions] c
	left outer join @XML.nodes('ROOT/DENO') as T(N) on T.N.value('@denoid', 'int') = c.DenoID
	where StockID = (select StockID from Accounting.LifeCycles where LifeCycleID = @LifeCycleID) and EndOfUseGamingDate is null
) c where c.Consegna <> 0


--e questo è quello che va in Chiusura

select c.DenoID,c.Chiusura,c.exrate
from
(
	select DenoID,InitialQty,ModuleValue ,
		T.N.value('@qty', 'int') as contato,
		T.N.value('@exrate', 'float') as exrate,
	[Accounting].[fn_StockCalculateConsegna] (
					[DenoID],
					T.N.value('@qty', 'int'),
					[InitialQty],
					[moduleValue],
					1
		)  as Consegna,
	T.N.value('@qty', 'int') - [Accounting].[fn_StockCalculateConsegna] (
					[DenoID],
					T.N.value('@qty', 'int'),
					[InitialQty],
					[moduleValue],
					1
		)  as Chiusura
	from  @XML.nodes('ROOT/DENO') as T(N)
	left outer join [CasinoLayout].[vw_AllStockCompositions]  c on T.N.value('@denoid', 'int') = c.DenoID
	where StockID = (select StockID from Accounting.LifeCycles where LifeCycleID = @LifeCycleID) and EndOfUseGamingDate is null
) c where c.Chiusura <> 0

*/

set @SnapshotTimeUTC = GetUTCDate()
set @SnapshotTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@SnapshotTimeUTC)


BEGIN TRANSACTION trn_CreateChiusuraTableXMLEx

BEGIN TRY  

	declare @XML xml = @values

	IF @CreateConsegna = 0  --Chiusura senza Consegna
	BEGIN

		insert into Accounting.tbl_Snapshots
			(
				LifeCycleID,
				UserAccessID,
				SnapshotTypeID,
				SnapshotTime,
				SnapshotTimeLoc
			)
		VALUES
			(
				@LifeCycleID,
				@UserAccessID,
				3,			--Chiusura snapshot type
				@SnapshotTimeUTC,
				@SnapshotTimeLoc
			)


		set @SnapshotID = @@IDENTITY --SCOPE_IDENTITY()


		-- 'inserting snapshot value'
		insert into Accounting.tbl_SnapshotValues
			( 
				LifeCycleSnapshotID ,
				DenoID ,
				Quantity ,
				ExchangeRate
			)
		select 
			@SnapshotID ,
			c.DenoID,
			c.Chiusura,
			c.exrate
		from
		(
			select DenoID,
				T.N.value('@exrate', 'float') as exrate,
				--contato 
				T.N.value('@qty', 'int')  as Chiusura
			from  @XML.nodes('ROOT/DENO') as T(N)
			left outer join [CasinoLayout].[vw_AllStockCompositions]  c on T.N.value('@denoid', 'int') = c.DenoID
			where StockID = (select StockID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID) and EndOfUseGamingDate is null
		) c where c.Chiusura <> 0
    end
	ELSE  --Chiusura con Consegna
	BEGIN

		DECLARE @ConsegnaTransID INT
		--first create Consegna transaction
		insert into Accounting.tbl_Transactions 
			(
				OpTypeID,
				SourceLifeCycleID,
				DestStockTypeID,
				DestStockID,
				SourceUserAccessID,
				SourceTime
			) 
		values
			(
				6					,	--Consegna per ripristino
				@LifeCycleID		,
				null				,
				null				,
				@UserAccessID		,
				@SnapshotTimeUTC		
			)

		set @ConsegnaTransID = @@IDENTITY

		--insert calculated Consegna
		--	print 'inserting new value'
		insert into Accounting.tbl_TransactionValues 
			(
				TransactionID,
				DenoID,
				Quantity,
				ExchangeRate,
				CashInbound
			)
		select 
			@ConsegnaTransID,
			c.DenoID,
			c.Consegna,
			c.exrate,
			0 --Consegna is cashout bound
		from
		(
			select DenoID,InitialQty,ModuleValue ,
				T.N.value('@qty', 'int') as Chiusura,
				T.N.value('@exrate', 'float') as exrate,

			[Accounting].[fn_StockCalculateConsegna] (
							[DenoID],
							T.N.value('@qty', 'int'),
							[InitialQty],
							[moduleValue],
							1
				)  as Consegna
			from [CasinoLayout].[vw_AllStockCompositions] c
			left outer join @XML.nodes('ROOT/DENO') as T(N) on T.N.value('@denoid', 'int') = c.DenoID
			where StockID = (select StockID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID) and EndOfUseGamingDate is null
		) c where c.Consegna <> 0


		--finally we can create the Chiusura snapshot
		insert into Accounting.tbl_Snapshots
			(
				LifeCycleID,
				UserAccessID,
				SnapshotTypeID,
				SnapshotTime,
				SnapshotTimeLoc
			)
		VALUES
			(
				@LifeCycleID,
				@UserAccessID,
				3,			--Chiusura snapshot type
				@SnapshotTimeUTC,
				@SnapshotTimeLoc
			)


		set @SnapshotID = @@IDENTITY --SCOPE_IDENTITY()


		-- 'inserting snapshot value'
		insert into Accounting.tbl_SnapshotValues
			( 
				LifeCycleSnapshotID ,
				DenoID ,
				Quantity ,
				ExchangeRate
			)
		select 
			@SnapshotID ,
			c.DenoID,
			c.Chiusura,
			c.exrate
		from
		(
			select DenoID,
				T.N.value('@exrate', 'float') as exrate,
				--contato - Consegna
				T.N.value('@qty', 'int') - [Accounting].[fn_StockCalculateConsegna] (
							[DenoID],
							T.N.value('@qty', 'int'),
							[InitialQty],
							[moduleValue],
							1
				)  as Chiusura
			from  @XML.nodes('ROOT/DENO') as T(N)
			left outer join [CasinoLayout].[vw_AllStockCompositions]  c on T.N.value('@denoid', 'int') = c.DenoID
			where StockID = (select StockID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID) and EndOfUseGamingDate is null
		) c where c.Chiusura <> 0



		--return back the recordset of the Consegna values
		select 
				TransactionID,
				DenoID,
				Quantity,
				ExchangeRate,
				CashInbound
		from Accounting.tbl_TransactionValues 
		where TransactionID = @ConsegnaTransID

	END



	--if a valid confirmation is specified insert an entry into confirmation table
	if (@ConfUserID is not null and @ConfUserGroupID is not null )
	begin
		if exists (select UserID from CasinoLayout.Users where UserID = @ConfUserID) 
		   and exists (select UserGroupID from CasinoLayout.UserGroups where UserGroupID = @ConfUserGroupID) 
		BEGIN
			--confirm Chiusura
			INSERT into Accounting.tbl_Snapshot_Confirmations 
				(LifeCycleSnapshotID,UserID,UserGroupID) 
				VALUES (@SnapshotID,@ConfUserID,@ConfUserGroupID)

			--also confirm Consegna
			IF @ConsegnaTransID IS NOT NULL
				insert into Accounting.tbl_Transaction_Confirmations
				(
					TransactionID,
					UserID,
					IsSourceConfirmation,
					UserGroupID
				)
				VALUES
				(   
					@ConsegnaTransID, -- TransactionID - int
					@ConfUserID, -- UserID - int
					1, -- IsSourceConfirmation - tinyint
					@ConfUserGroupID  -- UserGroupID - int
				)  
				      
		end
	end

	COMMIT TRANSACTION trn_CreateChiusuraTableXMLEx

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateChiusuraTableXMLEx
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	--stop here and return
END CATCH



  --finally log off useracces
EXECUTE @ret = [FloorActivity].[usp_LogOffUserAccess] 
   @UserAccessID
  ,0
GO
