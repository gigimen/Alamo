SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE function [CasinoLayout].[fn_GetUserPassword] (@UserID INT)
RETURNS @r TABLE (
	UserID			INT,
	FirstName		VARCHAR(256),
	LastName		VARCHAR(256),
	[LastPasswordChange]		datetime,
	[Password]		VARCHAR(64),
	[Password2]		VARCHAR(64),
	[Password3]		VARCHAR(64)
)
AS
BEGIN



/*

declare
@UserID INT

set @UserID = 3

select * from [CasinoLayout].[fn_GetUserPassword] (@UserID )
--*/


declare 
@decrPassword   VARCHAR(50),
@decrPassword2  VARCHAR(50),
@decrPassword3  VARCHAR(50),
@Password  varbinary(50),
@Password2 varbinary(50),
@Password3 varbinary(50)


select @Password = u.Password,
		@Password2 = u.Password2,
		@Password3 = u.Password3
from	CasinoLayout.Users u
where	u.UserID = @UserID


--password
IF @Password IS NOT NULL AND DATALENGTH(@Password) > 0
BEGIN
		EXEC master.dbo.xp_Decrypt @Password,@decrPassword OUTPUT 
END	
--password2
IF @Password2 IS NOT NULL AND DATALENGTH(@Password2) > 0
BEGIN
		EXEC master.dbo.xp_Decrypt @Password2,@decrPassword2 OUTPUT 
END	
--password3
IF @Password3 IS NOT NULL AND DATALENGTH(@Password3) > 0
BEGIN
		EXEC master.dbo.xp_Decrypt @Password3,@decrPassword3 OUTPUT 
END	

insert into @r
(
	UserID						,
	FirstName					,
	LastName					,
	[LastPasswordChange]		,
	[Password]					,
	[Password2]					,
	[Password3]					
)

select 
	UserID						,
	FirstName					,
	LastName					,
	[LastPasswordChange]		,
	@decrPassword   ,
	@decrPassword2  ,
	@decrPassword3  
from	CasinoLayout.Users u
where	u.UserID = @UserID

RETURN


end
GO
