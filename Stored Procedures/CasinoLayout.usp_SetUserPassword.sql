SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [CasinoLayout].[usp_SetUserPassword] 
@UserID INT,
@oldpassword VARCHAR(50),
@newpassword varchar(50),
@passwordStatus INT output
AS
/*

declare
@UserID INT,
@oldpassword VARCHAR(50),
@newpassword varchar(50),@passwordStatus int

set @UserID = 3

set @oldpassword = 'asdasd4'
set @newpassword = 'asdasd'



execute [CasinoLayout].[usp_SetUserPassword] 
@UserID ,
@oldpassword ,
@newpassword ,
@passwordStatus output

select @passwordStatus as passwordStatus

*/

/*

USE [master]
GO


EXEC sys.sp_addextendedproc N'[dbo].[xp_Encrypt]', 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Binn\xp_Blowfish.dll'
GO
EXEC sys.sp_addextendedproc N'[dbo].[xp_Decrypt]', 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Binn\xp_Blowfish.dll'
GO
EXEC sys.sp_addextendedproc N'[dbo].[xp_HelloWorld]', 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Binn\xp_Blowfish.dll'
GO
sys.sp_dropextendedproc @functname = N'[dbo].[xp_Encrypt]' -- nvarchar(517)
sys.sp_dropextendedproc @functname = N'[dbo].[xp_Decrypt]' -- nvarchar(517)
sys.sp_dropextendedproc @functname = N'[dbo].[xp_HelloWorld]' -- nvarchar(517)

--to free dll libraray
--  DBCC xp_Blowfish(FREE)

EXECUTE [dbo].[xp_HelloWorld]
GO


DECLARE @pwd VARBINARY(50),@decrypted VARCHAR(50)

SELECT @pwd = Password FROM Alamo.CasinoLayout.Users WHERE UserID = 3

SELECT @pwd,DATALENGTH(@pwd)
EXECUTE dbo.xp_Decrypt @pwd,@decrypted OUTPUT

SELECT @decrypted

GO




*/



/*

declare
@UserID INT

set @UserID = 3



--*/
declare 
@Password VARCHAR(50),
@Password2 VARCHAR(50),
@Password3 VARCHAR(50),
@EncrPassword varbinary(50),
@EncrPassword2 varbinary(50)


if @UserID is null or NOT EXISTS (
select 	u.UserID
from	CasinoLayout.Users u
where	u.UserID = @UserID
--	checks that this user has started working and is not fired
	and u.BeginDate < GetUTCDate() 
	and (u.EndDate is null or u.EndDate > GetUTCDate())
)
begin
		raiserror('Unrecognized UserID %d entered or the user has been disabled',16,1,@UserID)
		--return (-1)
end


select 
	@EncrPassword	 = [Password],
	@EncrPassword2	 = [Password2]
from	CasinoLayout.Users u
where UserID = @UserID 

select 
@Password = [Password],
@Password2 = [Password2],
@Password3 = [Password3]
from	[CasinoLayout].[fn_GetUserPassword] (@UserID )

--select @Password ,@EncrPassword,@Password2 ,@EncrPassword2,@Password3

IF @newpassword IS NULL OR LEN (@newpassword) < 6 
begin
		SET @passwordStatus = 3
		return (-1)
END




DECLARE @RC int


EXECUTE @RC = [CasinoLayout].[usp_CheckUserPassword] 
  @UserID
   ,@oldpassword
  ,@passwordStatus OUTPUT

--select @oldpassword,@UserID,@passwordStatus,@RC



IF @passwordStatus = 1 --password match
OR
--password was empty
(	@passwordStatus = 0 AND (@oldpassword IS NULL OR LEN(@oldpassword) = 0 ))
BEGIN

	--check against password2
	IF @Password IS NOT NULL AND DATALENGTH(@Password) > 0
	BEGIN
		IF @Password = ( @newpassword COLLATE Latin1_General_CS_AS)
		BEGIN
			--equal to @Password
			SET @passwordStatus = 2
			RETURN 0
		END
    END	--check against password2
	IF @Password2 IS NOT NULL AND DATALENGTH(@Password2) > 0
	BEGIN

		IF @Password2 = ( @newpassword COLLATE Latin1_General_CS_AS)
		BEGIN
			--equal to @Password2
			SET @passwordStatus = 2
			RETURN 0
		END
    END
	IF @Password3 IS NOT NULL AND DATALENGTH(@Password3) > 0
	BEGIN

		IF @Password3 = ( @newpassword COLLATE Latin1_General_CS_AS)
		BEGIN
			--equal to @Password2
			SET @passwordStatus = 2
			RETURN 0
		END
    END
	--proceed with the change of the password


	--encrypt password
	declare @CryptedPassword VARBINARY(50)
	EXEC master.dbo.xp_Encrypt @newpassword,@CryptedPassword OUTPUT


	UPDATE CasinoLayout.Users
	SET [Password] = @CryptedPassword,
	Password2 = @EncrPassword,
	Password3 = @EncrPassword2
	where	@UserID = UserID




	--run a check


	EXECUTE @RC = [CasinoLayout].[usp_CheckUserPassword] 
	   @UserID
	  ,@newpassword
	  ,@passwordStatus OUTPUT


	  IF @passwordStatus <> 1
	  BEGIN
			raiserror('Errore in encrytion/decryption!!!!',16,1,@UserID)
			return (-1)
	  END

end
RETURN @RC
GO
