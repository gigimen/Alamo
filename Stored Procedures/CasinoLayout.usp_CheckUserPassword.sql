SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [CasinoLayout].[usp_CheckUserPassword] 
@UserID int,
@password varchar(50),
@passwordStatus int output
AS


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
declare @CryptedPassword varbinary(50),@decrypted VARCHAR(50)

if @UserID is null or NOT EXISTS (
select 	u.UserID--,u.BeginDate,u.EndDate,GETUTCDATE()
from	CasinoLayout.Users u
where	u.UserID = @UserID
--	checks that this user has started working and is not fired
	and CAST(u.BeginDate AS DATE) <= CAST(GETUTCDATE() AS DATE) 
	and (u.EndDate is null or CAST(u.EndDate AS DATE) > CAST(GETUTCDATE() AS DATE))
)
begin
		raiserror('Unrecognized UserID %d entered or the user has been disabled',16,1,@UserID)
		return (-1)
end

select @CryptedPassword = [Password]
from	CasinoLayout.Users
where	@UserID = UserID

SET @passwordStatus = -1 --default return password mismatch


IF @CryptedPassword IS NULL OR DATALENGTH(@CryptedPassword) = 0
	SET @passwordStatus = 0 --password does not exists
ELSE
begin
	if  --we do have a password but we did not specify a password
		(@password is NOT NULL AND Len(@password) > 0) 
	begin

		--decrypt password
		EXEC master.dbo.xp_Decrypt @CryptedPassword,@decrypted OUTPUT

		--check password
	--	select @decrypted AS passworddecrypted,LEN(@decrypted)

		IF @decrypted = ( @password COLLATE Latin1_General_CS_AS)
			SET @passwordStatus = 1

	END
END
GO
