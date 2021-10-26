SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [CasinoLayout].[vw_LoginGroups]
AS
select 
ug.UserGroupID,
ug.FName as GroupName,
a.FName as ApplicationName,
au.AllowedActions,
cast((au.AllowedActions & 1) as bit) as CanLogin
from CasinoLayout.UserGroups ug
inner join [CasinoLayout].[UserGroup_Application]  au on ug.UserGroupID = au.UserGroupID
inner join GeneralPurpose.Applications a on a.ApplicationID = au.ApplicationID
where (AllowedActions & 1) = 1
GO
