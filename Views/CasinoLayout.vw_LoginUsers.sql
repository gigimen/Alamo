SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [CasinoLayout].[vw_LoginUsers]
AS
select 
ug.UserID,
ug.FirstName,
ug.LastName,
ug.loginName,
ug.UserGroupID,
ug.UserGroupName,
ug.ApplicationName,
ug.ApplicationID,
ug.AllowedActions
from [CasinoLayout].[vw_AllUsersAllowedActions] ug
where (AllowedActions & 1) = 1
GO
