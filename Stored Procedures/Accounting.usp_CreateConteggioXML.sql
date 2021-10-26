SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_CreateConteggioXML] 
@ssTypeID			INT					,
@GamingDate			DATETIME			,
@UAID				INT					,
@values				VARCHAR(MAX)		,
@ConteggioID		INT			OUTPUT  ,
@ConteggioTimeLoc	DATETIME	OUTPUT  ,
@ConteggioTimeUTC	DATETIME	OUTPUT  
AS
/*
--make sure the LifeCycleID correspond to the StockID
if @conteggioStockID is not null 
and @DestLifeCycleID is not null
and not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @DestLifeCycleID and StockID = @conteggioStockID)
begin
	raiserror('Wrong StockID (%d) for LifeCycleID (%d)',16,1,@conteggioStockID,@DestLifeCycleID)
	return(1)
end
*/

--make sure the @GamingDate is defined and does not exists yet
if @GamingDate is null 
begin
	raiserror('NULL @@GamingDate specified',16,1)
	RETURN(1)
END

if @ssTypeID is null or not exists 
(SELECT [SnapshotTypeID]
  FROM [CasinoLayout].[SnapshotTypes]
  where [SnapshotTypeID] = @ssTypeID)
begin
	raiserror('invalid @OpTypeID specified',16,1)
	RETURN(1)
END

declare @ret int
set @ret = 0

if @ssTypeID = 13 --conteggio met
begin

	raiserror('MET no more supported',16,1)
	RETURN(1)
END

/*

declare @t as varchar(max)
set @t = '<ROOT>
<DENO denoid="1" stockid="1" qty="0" exrate="1.58" />
<DENO denoid="2" stockid="2" qty="4" exrate="1.58" />
<DENO denoid="3" stockid="3" qty="123" exrate="1.58" />
</ROOT>'
declare @XML xml = @t
select 
T.N.value('@denoid', 'int') as DenoID,
T.N.value('@qty', 'int') as qty,
T.N.value('@stockid', 'int') as StockID,
T.N.value('@exrate', 'float') as exrate,
T.N.value('@qty', 'int') * T.N.value('@exrate', 'float') as value
from @XML.nodes('ROOT/DENO') as T(N)

declare @XML xml = @values

select 
T.N.value('@denoid', 'int') as DenoID,
T.N.value('@qty', 'int') as qty,
T.N.value('@stockid', 'int') as StockID,
T.N.value('@exrate', 'float') as exrate,
T.N.value('@qty', 'int') * T.N.value('@exrate', 'float') as value
from @XML.nodes('ROOT/DENO') as T(N)
*/







SELECT @ConteggioID = [ConteggioID]
  FROM [Accounting].[tbl_Conteggi]
where GamingDate = @GamingDate and [SnapshotTypeID] = @ssTypeID 

IF (@ConteggioID IS NOT NULL)
begin

	EXECUTE @ret = [Accounting].[usp_UpdateConteggioXML] 
		   @ConteggioID
		  ,@values
		  ,@UAID
	RETURN @ret
END
ELSE
BEGIN


BEGIN TRANSACTION trn_CreateConteggio

BEGIN TRY

	--we ave to create the Conteggio first
	set @ConteggioTimeUTC = GetUTCDate()

	INSERT INTO [Accounting].[tbl_Conteggi]
		([SnapshotTypeID]
		,[GamingDate]
		,[ConteggioTimeUTC]
		,[UserAccessID]
		)
	VALUES
		(@ssTypeID	
		,@GamingDate
		,@ConteggioTimeUTC
		,@UAID)

	SET @ConteggioID = @@IDENTITY


	IF @values IS NOT NULL AND LEN(@values) > 0
	BEGIN
		DECLARE @XML XML = @values

		--	print 'inserting new value'
		INSERT INTO [Accounting].[tbl_ConteggiValues]
			   ([ConteggioID]
			   ,[DenoID]
			   ,[StockID]
			   ,[Quantity]
			   ,[ExchangeRate])
 		SELECT 
		@ConteggioID ,
		T.N.value('@denoid', 'int'),
		T.N.value('@stockid', 'int'),
		T.N.value('@qty', 'int'),
		T.N.value('@exrate', 'float')
		FROM @XML.nodes('ROOT/DENO') AS T(N)
	END

	-- return SnapshotTime in local hour
	SET @ConteggioTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@ConteggioTimeUTC)

	COMMIT TRANSACTION trn_CreateConteggio

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateConteggio		
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

END

RETURN @ret
GO
