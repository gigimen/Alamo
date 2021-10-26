SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Accounting].[usp_OpenLifeCycleEx] 
@StockID int,
@UserID int,
@SiteID int,
@UserGroupID int,
@AppID INT,
@ConfirmUserID int,
@ConfirmUserGroupID int,
@conteggioentrata				varchar(max),
@LFID int output,
@LFSSID int output,
@GamingDate datetime output,
@OpenTimeLoc datetime output,
@OpenTimeUTC datetime output
AS


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

--then create lifecycle
EXECUTE @ret = [Accounting].[usp_OpenLifeCycle] 
   @StockID
  ,@UserAccessID
  ,@ConfirmUserID
  ,@ConfirmUserGroupID
  ,@LFID OUTPUT
  ,@LFSSID OUTPUT
  ,@GamingDate OUTPUT
  ,@OpenTimeLoc OUTPUT
  ,@OpenTimeUTC OUTPUT
IF @ret <> 0 RETURN @ret

DECLARE @SnapshotID int
DECLARE @SnapshotTimeLoc datetime
DECLARE @SnapshotTimeUTC datetime

EXECUTE @ret = [Accounting].[usp_CreateSnapShotXML] 
   @LFID
  ,@UserAccessID
  ,@ConfirmUserID
  ,@ConfirmUserGroupID
  ,5	--Conteggio Entrata
  ,@conteggioentrata
  ,@SnapshotID OUTPUT
  ,@SnapshotTimeLoc OUTPUT
  ,@SnapshotTimeUTC OUTPUT
IF @ret <> 0 RETURN @ret

  --finally log off useraccess

EXECUTE @Ret = [FloorActivity].[usp_LogOffUserAccess] 
   @UserAccessID
  ,0


RETURN @ret




GO
