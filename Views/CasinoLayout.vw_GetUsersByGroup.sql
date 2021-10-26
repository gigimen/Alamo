SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [CasinoLayout].[vw_GetUsersByGroup]
WITH SCHEMABINDING
AS
SELECT     	CasinoLayout.Users.UserID,
		FirstName,
		LastName,
		BeginDate,
		EndDate,
		CasinoLayout.UserGroup_User.UserGroupID,
		CasinoLayout.UserGroups.FName AS GroupName
FROM         	CasinoLayout.Users
INNER JOIN 	CasinoLayout.UserGroup_User ON CasinoLayout.Users.UserID = CasinoLayout.UserGroup_User.UserID
INNER JOIN	CasinoLayout.UserGroups ON CasinoLayout.UserGroups.UserGroupID = CasinoLayout.UserGroup_User.UserGroupID






GO
