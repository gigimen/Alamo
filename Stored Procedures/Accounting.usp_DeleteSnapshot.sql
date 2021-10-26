SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_DeleteSnapshot]
@ssID int,
@UserAccessID int
AS

--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specifie',16,1,@UserAccessID)
	return 1
end



if not exists 
	(
	select LifeCycleSnapshotID from Accounting.tbl_Snapshots 
		where LifeCycleSnapshotID = @ssID and Accounting.tbl_Snapshots.LCSnapShotCancelID is null
	)
begin
	raiserror('Invalid LifeCycleSnapshotID (%d) specified or already cancelled',16,1,@ssID)
	return 1
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteSnapshot

BEGIN TRY  


	declare @cancID int

	--first create a new TransactionCancelID 
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GetUTCDate(),@UserAccessID)
	
	set @cancID = @@IDENTITY
	--update the Chiusura snapshot
	update Accounting.tbl_Snapshots
		set Accounting.tbl_Snapshots.LCSnapShotCancelID = @cancID
		where LifeCycleSnapshotID = @ssID

	declare @attr varchar(256)
	set @attr = 'SnapshotID=''' + cast(@ssID as varchar(16)) + ''''
	execute [GeneralPurpose].[usp_BroadcastMessage] 'DeleteSnapshot',@attr

	COMMIT TRANSACTION trn_DeleteSnapshot

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteSnapshot
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	return @ret
END CATCH


return @ret
GO
