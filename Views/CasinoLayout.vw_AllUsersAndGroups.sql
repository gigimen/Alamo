SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [CasinoLayout].[vw_AllUsersAndGroups]
WITH SCHEMABINDING
AS
SELECT 
	u.loginName,
	u.UserID,
	u.FirstName,
	u.LastName,
	u.BeginDate,
	u.EndDate,
	u.EmailAddress,
	[GeneralPurpose].[GroupConcat](gps.FName) AS Groups
FROM   CasinoLayout.Users u
LEFT OUTER JOIN CasinoLayout.UserGroup_User ug ON u.UserID = ug.UserID
LEFT OUTER JOIN	CasinoLayout.UserGroups gps ON gps.UserGroupID = ug.UserGroupID
GROUP BY u.loginName,u.UserID,
	u.FirstName,
	u.LastName,
	u.BeginDate,
	u.EmailAddress,
	u.EndDate







GO
