SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [CasinoLayout].[usp_ForceUserPassword] 
@UserID INT,
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
@loginName varchar(50),
@AppID int,
@password varchar(50),
@UserID int ,
@passwordStatus int 


set @UserID = 3
set @password = 'asdasd'

set @AppID = 3122003

--*/
declare 
@CryptedPassword VARBINARY(50),
@decrypted VARCHAR(50),
@Password0 varbinary(50),
@Password1 varbinary(50),
@Password2 varbinary(50)


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
		return (-1)
end

select @Password0 = u.Password,
		@Password1 = u.Password2,
		@Password2 = u.Password3
from	CasinoLayout.Users u
where	u.UserID = @UserID

IF @newpassword IS NULL OR LEN (@newpassword) < 6 
begin
		SET @passwordStatus = 3
		return (-1)
END


DECLARE @RC int


--check against password2
IF @Password1 IS NOT NULL AND DATALENGTH(@Password1) > 0
BEGIN
	EXEC master.dbo.xp_Decrypt @Password1,@decrypted OUTPUT 

	IF @decrypted = ( @newpassword COLLATE Latin1_General_CS_AS)
	BEGIN
		--equal to password2
		SET @passwordStatus = 2
		RETURN 0
	END
END	--check against password2
IF @Password2 IS NOT NULL AND DATALENGTH(@Password2) > 0
BEGIN
	EXEC master.dbo.xp_Decrypt @Password2,@decrypted OUTPUT 

	IF @decrypted = ( @newpassword COLLATE Latin1_General_CS_AS)
	BEGIN
		--equal to password3
		SET @passwordStatus = 2
		RETURN 0
	END
END
--proceed with the change of the password


--encrypt password
EXEC master.dbo.xp_Encrypt @newpassword,@CryptedPassword OUTPUT


UPDATE CasinoLayout.Users
SET [Password] = @CryptedPassword,
Password2 = @Password0,
Password3 = @Password1
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

RETURN @RC
GO
