SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [FloorActivity].[usp_AuthenticateUserEx] 
@loginName varchar(50),
@AppID int,
@password varchar(50),
@UserID int output,
@passwordStatus int output
AS
if @AppID is null or  not exists (SELECT ApplicationID from [GeneralPurpose].[Applications] where ApplicationID=@AppID)
begin
	raiserror('Invalid AppID %d specified',16,1,@AppID)
	return (-1)
end



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

if @UserID is null or @UserID = 0
begin
	if @loginName is null or len(@loginName) = 0
	begin
		raiserror('Invalid login name specified',16,1)
		--return (-1)
	end
	

	select @UserID = UserID
	from	CasinoLayout.Users
	where	loginName = @loginName
end
if @UserID is null or @UserID = 0
begin
		raiserror('Unrecognized user entered',16,1)
		--return (-1)
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


--SELECT @passwordStatus AS passwordStatus



select  
	u.LastName,
	u.FirstName,
	u.loginName,
	u.EMailAddress,
	uug.UserGroupID,
	ug.RoleName,
	uga.AllowedActions,
	uga.ApplicationID
from	CasinoLayout.Users u
	inner join CasinoLayout.UserGroup_User uug on u.UserID = uug.UserID 
	inner join CasinoLayout.UserGroups ug ON uug.UserGroupID = ug.UserGroupID 
	inner join CasinoLayout.UserGroup_Application uga ON uga.UserGroupID = uug.UserGroupID
where	u.UserID = @UserID
--	checks that this user has started working and is not fired
	and u.BeginDate < GetUTCDate() 
	and (u.EndDate is null or u.EndDate > GetUTCDate())
	and uga.ApplicationID = @AppID
GO
