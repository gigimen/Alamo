SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_CreateConteggioChiusuraIncassoXML] 
@gamigdate			DATETIME,
@UserAccessID		INT,
@values				VARCHAR(MAX),
@SnapshotID			INT OUTPUT,
@SnapshotTimeLoc	DATETIME OUTPUT,
@SnapshotTimeUTC	DATETIME OUTPUT
AS

if @gamigdate is null 
begin
	raiserror('Invalid @gamigdate specified',16,1)
	RETURN 1
END

IF @values is NULL OR LEN(@values) = 0
begin
	raiserror('Must specify Chiusura values',16,1)
	RETURN 1
END

declare @LifeCycleID int,@ret int

select @LifeCycleID = LifeCycleID
from Accounting.tbl_LifeCycles 
where StockID = 47 and GamingDate = @gamigdate

IF @LifeCycleID IS NULL 
BEGIN
	raiserror('Incasso non è stato aperto per il gaming date specificato',16,1)
	return 1
END

/*

set @LifeCycleID = 160363

declare @t as varchar(max)
set @t = '<ROOT>
<DENO denoid="103" stockid="75" qty="0" exrate="1.0" />  --kiosk-chf1
<DENO denoid="103" stockid="79" qty="0" exrate="1.0" />  --kiosk-chf2
<DENO denoid="103" stockid="85" qty="0" exrate="1.0" />  --gastro
<DENO denoid="163" stockid="80" qty="0" exrate="1.0" />  --kiosk-eur1
<DENO denoid="163" stockid="81" qty="0" exrate="1.0" />  --kiosk-eur2
<DENO denoid="103" stockid="83" qty="0" exrate="1.0" /> --tronc gastro
</ROOT>'
declare @XML xml = @t
select 
T.N.value('@denoid', 'int') as DenoID,
T.N.value('@qty', 'int') as conteggiouscita,
T.N.value('@stockid', 'int') as stockid,
T.N.value('@exrate', 'float') as exrate,
T.N.value('@qty', 'int') * T.N.value('@exrate', 'float') as value
from @XML.nodes('ROOT/DENO') as T(N)


*/

SET @SnapshotTimeUTC = GETUTCDATE()
SET @SnapshotTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@SnapshotTimeUTC)


--look for conteggio uscita
SELECT @SnapshotID = LifeCycleSnapshotID 
FROM Accounting.tbl_Snapshots 
WHERE LifeCycleID = @LifeCycleID AND SnapshotTypeID = 6  --conteggio uscita

IF @SnapshotID IS NULL 
	EXECUTE @ret = [Accounting].[usp_CreateSnapShotXML] 
	   @LifeCycleID
	  ,@UserAccessID
	  ,NULL --@ConfUserID
	  ,NULL --@ConfUserGroupID
	  ,6 --@SSTypeID conteggio uscita
	  ,@values
	  ,@SnapshotID OUTPUT
	  ,@SnapshotTimeLoc OUTPUT
	  ,@SnapshotTimeUTC OUTPUT
ELSE

	EXECUTE @ret = [Accounting].[usp_UpdateSnapshotXML] 
	   @SnapshotID
	  ,@values
	  ,@UserAccessID


RETURN @ret
GO
