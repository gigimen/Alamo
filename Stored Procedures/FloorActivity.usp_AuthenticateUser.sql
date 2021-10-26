SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [FloorActivity].[usp_AuthenticateUser] 
@loginName varchar(50),
@AppID int,
@UserID int output
AS
if @AppID is null or  not exists (SELECT ApplicationID from [GeneralPurpose].[Applications] where ApplicationID=@AppID)
begin
	raiserror('Invalid AppID %d specified',16,1,@AppID)
	return (-1)
end

if @UserID is null or @UserID = 0
begin
	if @loginName is null or len(@loginName) = 0
	begin
		raiserror('Invalid login name specified',16,1)
		return (-1)
	end
	
	select @UserID = UserID
	from	CasinoLayout.Users
	where	loginName = @loginName


	select  CasinoLayout.Users.Password,
		CasinoLayout.Users.LastName,
		CasinoLayout.Users.FirstName,
		CasinoLayout.Users.loginName,
		CasinoLayout.Users.EMailAddress,
		CasinoLayout.UserGroup_User.UserGroupID,
		CasinoLayout.UserGroups.RoleName,
		CasinoLayout.UserGroup_Application.AllowedActions
	from	CasinoLayout.Users
		inner join CasinoLayout.UserGroup_User
		on CasinoLayout.Users.UserID = CasinoLayout.UserGroup_User.UserID 
		inner join CasinoLayout.UserGroups
		on CasinoLayout.UserGroup_User.UserGroupID = CasinoLayout.UserGroups.UserGroupID 
		inner join CasinoLayout.UserGroup_Application
		on CasinoLayout.UserGroup_Application.UserGroupID = CasinoLayout.UserGroup_User.UserGroupID
	where	CasinoLayout.Users.loginName = @loginName
	--	checks that this user has started working and is not fired
		and CasinoLayout.Users.BeginDate < GetUTCDate() 
		and (CasinoLayout.Users.EndDate is null or CasinoLayout.Users.EndDate > GetUTCDate())
		and CasinoLayout.UserGroup_Application.ApplicationID = @AppID
end
else
--if we specify a UserID

select 	CasinoLayout.Users.Password,
	CasinoLayout.Users.LastName,
	CasinoLayout.Users.FirstName,
	CasinoLayout.Users.loginName,
	CasinoLayout.Users.EMailAddress,
	CasinoLayout.UserGroup_User.UserGroupID,
	CasinoLayout.UserGroups.RoleName,
	CasinoLayout.UserGroup_Application.AllowedActions
from	CasinoLayout.Users
	inner join CasinoLayout.UserGroup_User
	on CasinoLayout.Users.UserID = CasinoLayout.UserGroup_User.UserID 
	inner join CasinoLayout.UserGroups
	on CasinoLayout.UserGroup_User.UserGroupID = CasinoLayout.UserGroups.UserGroupID 
	inner join CasinoLayout.UserGroup_Application
	on CasinoLayout.UserGroup_Application.UserGroupID = CasinoLayout.UserGroup_User.UserGroupID
where	CasinoLayout.Users.UserID = @UserID
--	checks that this user has started working and is not fired
	and CasinoLayout.Users.BeginDate < GetUTCDate() 
	and (CasinoLayout.Users.EndDate is null or CasinoLayout.Users.EndDate > GetUTCDate())
	and CasinoLayout.UserGroup_Application.ApplicationID = @AppID
GO
GRANT EXECUTE ON  [FloorActivity].[usp_AuthenticateUser] TO [LRDManagement]
GO
GRANT EXECUTE ON  [FloorActivity].[usp_AuthenticateUser] TO [SolaLetturaNoDanni]
GO
GRANT EXECUTE ON  [FloorActivity].[usp_AuthenticateUser] TO [TecRole]
GO
