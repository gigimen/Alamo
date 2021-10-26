SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Snoopy].[usp_ExecuteBonifico]
@BonificoID int,
@UserAccessID int,
@ExecTime datetime output
AS


--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specified',16,1,@UserAccessID)
	return 1
end

if not exists (select BonificoID from Snoopy.tbl_Bonifici where BonificoID = @BonificoID)
begin
	raiserror('Invalid BonificoID (%d) specified',16,1,@BonificoID)
	return 2
end
if exists (select BonificoID from Snoopy.tbl_Bonifici where BonificoID = @BonificoID and ExecTimeStampUTC is not null)
begin
	raiserror('Bonifico (%d) already executed!',16,1,@BonificoID)
	return 2
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_ExecuteBonifico

BEGIN TRY  



	set @ExecTime = GETUTCDATE()

	UPDATE Snoopy.tbl_Bonifici
	   SET [ExecTimeStampUTC] = @ExecTime
		  ,[ExecUserAccessID] = @UserAccessID
	 WHERE BonificoID = @BonificoID




	set @ExecTime = GeneralPurpose.fn_UTCToLocal(1,@ExecTime)

	COMMIT TRANSACTION trn_ExecuteBonifico

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ExecuteBonifico
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
