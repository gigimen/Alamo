SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [ForIncasso].[usp_CopyMainstockComposition]
@GamingDate DATETIME
AS

DECLARE 
	@StockID INT,
	@UserAccessID INT,
	@ConfirmUserID INT,
	@ConfirmUserGroupID INT,
	@LifeCycleID INT,
	@SnapshotID INT,
	@OpenTimeLoc DATETIME,
	@OpenTimeUTC DATETIME,
	@ret  INT,
	@Values VARCHAR(MAX)


SET @StockID=31
--SET @GamingDate = '3.13.2020'

IF EXISTS 
(
SELECT LifeCycleID FROM Accounting.vw_AllStockLifeCycles WHERE StockID = @StockID AND @GamingDate = GamingDate
)
BEGIN
	raiserror('Mainstock already opened!!',16,1)
	return 1
END


SELECT @SnapshotID = ChiusuraSnapshotID FROM [Accounting].[vw_LastGamingDateLifeCycles] WHERE StockID = @StockID 
IF @SnapshotID IS NULL 
BEGIN
	raiserror('Mainstock has to be closed!!',16,1)
	return 1
END
--PRINT @GamingDate

--SELECT DenoID,Quantity,ExchangeRate FROM Accounting.vw_AllSnapshotDenominations WHERE LifeCycleSnapshotID = @SnapshotID

SELECT @Values = [Accounting].[fn_XMLSnapshotValues] (@SnapshotID)


--	@Values=<ROOT><DENO denoid="1" exrate="1.000000" qty="4" /><DENO denoid="2" exrate="1.000000" qty="4" /><DENO denoid="3" exrate="1.000000" qty="4" /><DENO denoid="4" exrate="1.000000" qty="4" /><DENO denoid="5" exrate="1.000000" qty="4" /><DENO denoid="6" exrate="1.000000" qty="4" /><DENO denoid="7" exrate="1.000000" qty="4" /><DENO denoid="8" exrate="1.000000" qty="4" /><DENO denoid="9" exrate="1.000000" qty="4" /><DENO denoid="78" exrate="1.000000" qty="4" /><DENO denoid="128" exrate="1.000000" qty="4" /><DENO denoid="129" exrate="1.000000" qty="4" /><DENO denoid="130" exrate="1.000000" qty="4" /><DENO denoid="131" exrate="1.000000" qty="4" /><DENO denoid="132" exrate="1.000000" qty="4" /><DENO denoid="133" exrate="1.000000" qty="4" /><DENO denoid="134" exrate="1.000000" qty="4" /><DENO denoid="135" exrate="1.000000" qty="4" /><DENO denoid="136" exrate="1.000000" qty="4" /><DENO denoid="195" exrate="1.000000" qty="4" /><DENO denoid="196" exrate="1.000000" qty="4" /><DENO denoid="197" exrate="1.000000" qty="4" /><DENO denoid="198" exrate="1.000000" qty="4" /><DENO denoid="199" exrate="1.000000" qty="4" /><DENO denoid="200" exrate="1.000000" qty="4" /><DENO denoid="201" exrate="1.000000" qty="4" /><DENO denoid="202" exrate="1.000000" qty="4" /><DENO denoid="203" exrate="1.000000" qty="4" /></ROOT>

/*
DECLARE @XML xml = @Values

SELECT 
	T.N.value('@denoid', 'int') AS DenoID,
	cast(T.N.value('@qty', 'float') as int) AS [Quantity],
	T.N.value('@exrate', 'float') AS [ExchangeRate]
from @XML.nodes('ROOT/DENO') as T(N)

*/


--SET	@UserAccessID=1
--first create new user access
EXECUTE @ret =  [FloorActivity].[usp_CreateUserAccess] 
122,--@SiteID INT, ws-incasso
3, --@UserID INT, lmenegolo
13, --@UserGroupID INT, incasso managers
310387, --@AppID INT, incasso application
@UserAccessID  OUTPUT
IF @ret <> 0
	RETURN @ret


SET	@ConfirmUserID=353 --imbesi
SET	@ConfirmUserGroupID=14 --incasso operators

--open lifecycle of MS
EXECUTE @ret =  [Accounting].[usp_OpenLifeCycle]
	@StockID			,
	@UserAccessID	,
	@ConfirmUserID	,
	@ConfirmUserGroupID	,
	@LifeCycleID	OUTPUT,
	@SnapshotID		OUTPUT,
	@GamingDate		OUTPUT,
	@OpenTimeLoc	OUTPUT,
	@OpenTimeUTC	OUTPUT
IF @ret <> 0
	RETURN @ret

--create snapshot apertura mainstock
execute @ret =   [Accounting].[usp_CreateSnapShotXML]
	@LifeCycleID,
	@UserAccessID,
	@ConfirmUserID,
	@ConfirmUserGroupID,
	5, --conteggio entrata
	@Values,
	@SnapshotID		OUTPUT,
	@OpenTimeLoc	OUTPUT,
	@OpenTimeUTC	OUTPUT
IF @ret <> 0
	RETURN @ret


--14-03-20 11:04:27 - Chiusura Main Stock by Stefano Raffa and confirmed by Giancarlo Besomi
execute @ret = [Accounting].[usp_CreateSnapshotXML]
	@LifeCycleID,
	@UserAccessID,
	@ConfirmUserID,
	@ConfirmUserGroupID,
	3,  --Chiusura snapshot
	@Values,
	@SnapshotID		OUTPUT,
	@OpenTimeLoc	OUTPUT,
	@OpenTimeUTC	OUTPUT

IF @ret <> 0
	RETURN @ret
GO
