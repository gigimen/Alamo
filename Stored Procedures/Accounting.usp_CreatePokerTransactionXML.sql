SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_CreatePokerTransactionXML] 
@credit				BIT		,
@sourceStockID		INT		,
@DestLifeCycleID	INT		,
@SourceUAID			INT		,
@values				VARCHAR(MAX),
@sourceLifeCycleID	INT			OUTPUT	,
@TransID			INT			OUTPUT  ,
@TransTimeLoc		DATETIME	OUTPUT  ,
@TransTimeUTC		DATETIME	OUTPUT  ,
@pending			INT			OUTPUT
AS

DECLARE @gamingdate	DATETIME,
@ret				INT,
@closeTable			BIT

set @ret = 0
SET @closeTable = 0

--make sure the @DestLifeCycleID correspond to the CC
SELECT @gamingdate = GamingDate 
FROM Accounting.vw_AllStockLifeCycles 
WHERE LifeCycleID = @DestLifeCycleID and StockID = 46 AND AperturaSnapshotID IS NOT NULL
IF @gamingdate IS null
begin
	raiserror('Wrong @DestLifeCycleID (%d) specified',16,1,@DestLifeCycleID)
	return(1)
end


IF NOT EXISTS
(
select StockID from [CasinoLayout].[Stocks] where StockID = @sourceStockID AND stocktypeID = 23
)
begin
	raiserror('StockID (%d) is not a poker table',16,1,@sourceStockID)
	return(1)
end

SELECT @sourceLifeCycleID = lf.LifeCycleID 
FROM Accounting.tbl_LifeCycles lf
WHERE lf.GamingDate = @gamingdate AND lf.StockID = @sourceStockID

--make sure the SourceLifeCycleID exists
if @sourceLifeCycleID is null 
BEGIN

	IF @credit = 1
	BEGIN
		raiserror('StockID (%d) is not open: credit not possible!',16,1,@sourceStockID)
		return(1)
    END

	--we have to open the lifecycle
	declare @stockLFSSID INT

	print 'Open the stock ' + str(@sourceStockID)
	EXEC @ret = Accounting.usp_OpenLifeCycle 
			@sourceStockID,
			@SourceUAID,
			null,
			null,
			@sourceLifeCycleID output,
			@stockLFSSID output,
			@gamingdate output,
			@TransTimeLoc output,
			@TransTimeUTC output
	IF @ret <> 0
		RETURN @ret
	set @pending = 0
END
ELSE 
BEGIN
	--make sure we don't have already 1 pending fill for that pocker table
	
	SELECT @pending = Pending
	FROM Accounting.vw_PokerCreditFills
	WHERE LifeCycleID = @sourceLifeCycleID 

	IF @credit = 0 --in caso di fill
	begin
		IF @pending >= 2
		BEGIN
 			raiserror('Il tavolo ha già una consegna pendente',16,1)
			return(1)   
		END
	END
	ELSE
	BEGIN
		IF @pending = 1
			SET @closeTable = 1
    END
END



/*

IF @credit = 1 AND @closeTable = 1
BEGIN
 			raiserror('Il tavolo verrà chiuso',16,1)
			return(1)   
END
RETURN 0
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


BEGIN TRANSACTION trn_CreatePokerTransaction

BEGIN TRY 

	--we ave to create the transaction first
	set @TransTimeUTC = GetUTCDate()
	insert into Accounting.tbl_Transactions 
		(
			OpTypeID,
			SourceLifeCycleID,
			DestStockTypeID,
			DestStockID,
			DestLifeCycleID,
			SourceUserAccessID,
			SourceTime) 
	values(
				CASE WHEN @credit = 1 THEN 4 ELSE 1 end	, --ACCONTO == FILL
				@sourceLifeCycleID		,
				7	,		--CC StockTypeID
				46	,		--CC StockID
				@DestLifeCycleID	,
				@SourceUAID		,
				@TransTimeUTC		
				)


	SET @TransID = @@IDENTITY

	IF @values IS NOT NULL AND LEN(@values) > 0
	BEGIN
		DECLARE @XML XML = @values

		--	print 'inserting new value'
		INSERT INTO Accounting.tbl_TransactionValues 
		(TransactionID,DenoID,Quantity,ExchangeRate,CashInbound)
		--	values( @DenoID,@qty,@exchange,@CashInbound)
		SELECT 
		@transID ,
		T.N.value('@denoid', 'int'),
		T.N.value('@qty', 'int'),
		T.N.value('@exrate', 'float'),
		T.N.value('@CashInbound', 'bit')
		FROM @XML.nodes('ROOT/DENO') AS T(N)
	END


	-- return SnapshotTime in local hour
	SET @TransTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@TransTimeUTC)


	IF @credit = 1 AND @closeTable = 1
	BEGIN
		--create the Chiusura snapshot
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
				@sourceLifeCycleID,
				@SourceUAID,
				3,			--Chiusura snapshot type
				@TransTimeUTC,
				@TransTimeLoc
			)
	
	END

	COMMIT TRANSACTION trn_CreatePokerTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreatePokerTransaction	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret

GO
