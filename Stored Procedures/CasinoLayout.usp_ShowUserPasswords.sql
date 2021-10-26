SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [CasinoLayout].[usp_ShowUserPasswords] 
@UserID INT,
@password0 varchar(50) OUTPUT,
@password1 varchar(50) OUTPUT,
@password2 varchar(50) OUTPUT
AS
/*

declare
@UserID INT,
@password0 varchar(50) ,
@password1 varchar(50) ,
@password2 varchar(50) 

set @UserID = 7

execute [CasinoLayout].[usp_ShowUserPasswords]
@UserID ,
@password0 	  output,
@password1 	  output,
@password2 	  output

select @password0 as password0, @password1 as password1,@password2 as password2

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
select  
@password0 = [Password],
@password1 = [Password2],
@password2 = [Password3]
from [CasinoLayout].[fn_GetUserPassword] (@UserID )

SELECT LastPasswordChange FROM Alamo.CasinoLayout.Users WHERE UserID = @UserID

RETURN 0
GO
