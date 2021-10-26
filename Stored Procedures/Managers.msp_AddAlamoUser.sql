SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Managers].[msp_AddAlamoUser]
@nome    varchar(50),
@cognome varchar(50),
@gruppo  varchar(50),
@lnome   varchar(50)
AS
	if (@nome is null or LEN(@nome)=0)
	begin
		raiserror('Must specify the user first name',16,-1)
		return (1)
	end
	if (@cognome is null or LEN(@cognome)=0)
	begin
		raiserror('Must specify the user last name',16,-1)
		return (1)
	end
	if (@gruppo is null or LEN(@gruppo)=0)
	begin
		raiserror('Must specify the gruppo name',16,-1)
		return (1)
	end
	declare @UserGroupID int
	set @UserGroupID = (select UserGroupID from CasinoLayout.UserGroups where FName = @gruppo)
	if (@UserGroupID is null)
	begin
		raiserror('Must specify an existing gruppo name',16,-1)
		return (1)
	end
	if @lnome is null or @lnome = ''
	begin
		--get rid of nomi
		set @lnome = LOWER(SUBSTRING (@nome,1,1)) + LOWER(REPLACE(@cognome,' ',''))
		print @lnome
	end
	declare @UserID int
	set @UserID = (select UserID from CasinoLayout.Users where loginName = @lnome)
	if(@UserID = null)
	begin
		declare @begDate smalldatetime
		set @begDate = GetUTCDate()
		--get rid of hours and minutes which are not neeeded
		set @begDate = DATEADD(hh,-DATEPART(hh,@begDate),@begDate)
		set @begDate = DATEADD(mi,-DATEPART(mi,@begDate),@begDate)
		INSERT INTO CasinoLayout.Users 	
		(LoginName,FirstName,LastName,BeginDate) 
		VALUES(@lnome,@nome,@cognome,@begDate)
		set @UserID = (select UserID from CasinoLayout.Users where loginName = @lnome)
		print 'New user id for ' + @nome + ' ' + @cognome + ': ' + STR(@UserID)
	end
	if @@error = 0
		--link user to the specified user group
		INSERT INTO CasinoLayout.UserGroup_User 
			(UserID,UserGroupID) 
			VALUES(@UserID,@UserGroupID)

GO
