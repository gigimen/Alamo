SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_CreateTransactionXML] 
@OpTypeID			INT		,
@sourceLCID			INT		,
@destStockTypeID	INT		,
@DestStockID		INT		,
--@DestLifeCycleID	INT		,
@SourceUAID			INT		,
@ConfUserID			INT		,
@ConfUserGroupID	INT		,
@values				varchar(max),
@TransID			INT			OUTPUT  ,
@TransTimeLoc		DATETIME	OUTPUT  ,
@TransTimeUTC		DATETIME	OUTPUT  
AS
/*
--make sure the LifeCycleID correspond to the StockID
if @DestStockID is not null 
and @DestLifeCycleID is not null
and not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @DestLifeCycleID and StockID = @DestStockID)
begin
	raiserror('Wrong StockID (%d) for LifeCycleID (%d)',16,1,@DestStockID,@DestLifeCycleID)
	return(1)
end
*/
--make sure the LifeCycleID correspond to the StockID
if @DestStockID is not null 
and @destStockTypeID is not null
and not exists (select StockID from CasinoLayout.Stocks where StockTypeID = @destStockTypeID and StockID = @DestStockID)
begin
	raiserror('Wrong StockTypeID (%d) for StockID (%d)',16,1,@destStockTypeID,@DestStockID)
	return(1)
end
if @OpTypeID = 5 --ripristino
begin
	--check that ripristino has not been created already
	
	if exists ( select TransactionID from Accounting.tbl_Transactions where SourceLifeCycleID = @sourceLCID and DestStockID = @DestStockID )
	begin
		raiserror('Ripristino for stock %d already created',16,-1,@DestStockID)
		return (1)
	end
end

if (@TransID is not null)
begin
	raiserror('Cannot specify @TransID or @opID use procedure [Accounting].[usp_UpdateTransactionXML] to modify an existing transaction' ,16,-1)
	return (1)
end


if	(@ConfUserID is not null and @ConfUserGroupID is not null )
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
<DENO denoid="1" qty="0" exrate="1.58" CashInbound="1" />
<DENO denoid="2" qty="4" exrate="1.58" CashInbound="0" />
<DENO denoid="3" qty="123" exrate="1.58" CashInbound="1" />
</ROOT>'
declare @XML xml = @t
select 
T.N.value('@denoid', 'int') as DenoID,
T.N.value('@qty', 'int') as qty,
T.N.value('@exrate', 'float') as exrate,
T.N.value('@CashInbound', 'bit') as CashInbound,
T.N.value('@qty', 'int') * T.N.value('@exrate', 'float') as value
from @XML.nodes('ROOT/DENO') as T(N)

declare @XML xml = @values

select 
T.N.value('@denoid', 'int') as DenoID,
T.N.value('@qty', 'int') as qty,
T.N.value('@exrate', 'float') as exrate,
T.N.value('@CashInbound', 'bit') as CashInbound,
T.N.value('@qty', 'int') * T.N.value('@exrate', 'float') as value
from @XML.nodes('ROOT/DENO') as T(N)
*/

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateTransaction

BEGIN TRY 

	--we ave to create the transaction first
	set @TransTimeUTC = GetUTCDate()
	insert into Accounting.tbl_Transactions 
		(
			OpTypeID,
			SourceLifeCycleID,
			DestStockTypeID,
			DestStockID,
	--		DestLifeCycleID,
			SourceUserAccessID,
			SourceTime) 
			values(
				@OpTypeID		,
				@sourceLCID		,
				@destStockTypeID	,
				@DestStockID		,
	--			@DestLifeCycleID	,
				@SourceUAID		,
				@TransTimeUTC		
				)


	set @TransID = @@IDENTITY

	--if a valid confirmation is specified insert an entry into confirmation table
	if	(@ConfUserID is not null and @ConfUserGroupID is not null )
	begin
		if exists (select UserID from CasinoLayout.Users where UserID = @ConfUserID) 
			and exists (select UserGroupID from CasinoLayout.UserGroups where UserGroupID = @ConfUserGroupID) 
		begin
		--since it is an transaction creation insert 1 in field IsSourceConfirmation
			insert into Accounting.tbl_Transaction_Confirmations 
				(TransactionID,IsSourceConfirmation,UserID,UserGroupID) 
				VALUES (@TransID,1,@ConfUserID,@ConfUserGroupID)
		end
	end

	IF @values is NOT NULL AND LEN(@values) > 0
	begin
		declare @XML xml = @values


		--	print 'inserting new value'
		insert into Accounting.tbl_TransactionValues 
		(TransactionID,DenoID,Quantity,ExchangeRate,CashInbound)
		--	values( @DenoID,@qty,@exchange,@CashInbound)
		select 
		@transID ,
		T.N.value('@denoid', 'int'),
		T.N.value('@qty', 'int'),
		T.N.value('@exrate', 'float'),
		T.N.value('@CashInbound', 'bit')
		from @XML.nodes('ROOT/DENO') as T(N)
	END

	-- return SnapshotTime in local hour
	set @TransTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@TransTimeUTC)

	COMMIT TRANSACTION trn_CreateTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateTransaction	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
