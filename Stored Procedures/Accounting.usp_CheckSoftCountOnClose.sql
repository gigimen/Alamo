SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_CheckSoftCountOnClose]
@lfCyID int
AS


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CheckSoftCountOnClose

BEGIN TRY  


	declare @closeDateUTC datetime
	if not exists
		(select LifeCycleID
			from Accounting.tbl_LifeCycles 
			where 
			LifeCycleID = @lfCyID
		)
	begin
		raiserror('LiferCycle does not exists',16,-1)
	end
	else
	begin
		set  @closeDateUTC = 
			(
			select SnapshotTime
				from Accounting.tbl_Snapshots 
				where LifeCycleID = @lfCyID 
				AND SnapshotTypeID  = 3 --'Chiusura')
				AND Accounting.tbl_Snapshots.LCSnapshotCancelID is null
			)
		if ( @closeDateUTC is null)
		begin
			raiserror('Table is not closed',16,-1)
		end
		else
		begin
			--make sure we do not delete the soft count entered few minutes before closing
			set @closeDateUTC = dateadd(mi,30, @closeDateUTC)
			print 'deleting data'
			delete from Accounting.tbl_Progress 
				where 
				LifeCycleID = @lfCyID 	AND
				StateTime > @closeDateUTC
		end
	end


	COMMIT TRANSACTION trn_CheckSoftCountOnClose

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CheckSoftCountOnClose
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
