SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [FloorActivity].[usp_ChangePassword] 
@UserID int,
@NewPassword varbinary(12)
AS
if @UserID is null or @UserID not in (select UserID from CasinoLayout.Users)
begin
	raiserror('Wrong user id specified',16,1)
	return (-1)
end

declare @curpass varbinary(50)
declare @passwd1 varbinary(50)

select @curpass = Password,
	@passwd1 = Password2
	from CasinoLayout.Users
	where UserID = @UserID

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_ChangePassword

BEGIN TRY  



	update 	CasinoLayout.Users
		set Password = @NewPassword,
		Password2 = @curpass,
		Password3 = @passwd1,
		LastPasswordChange = GetUTCDate()
		where UserID = @UserID

	COMMIT TRANSACTION trn_ChangePassword

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ChangePassword
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
GO
