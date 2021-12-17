SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [CasinoLayout].[vw_AllUsersAllowedActions]
WITH SCHEMABINDING
AS
SELECT     
CasinoLayout.Users.FirstName, 
CasinoLayout.Users.LastName, 
CasinoLayout.Users.EmailAddress, 
CasinoLayout.UserGroups.UserGroupID, 
CasinoLayout.UserGroups.FName AS UserGroupName, 
CasinoLayout.UserGroup_Application.AllowedActions, 
CasinoLayout.UserGroup_Application.ApplicationID, 
[GeneralPurpose].[Applications].FName AS ApplicationName, 
CasinoLayout.Users.UserID, 
CasinoLayout.Users.loginName,
CasinoLayout.UserGroup_User.SectorID
FROM         [GeneralPurpose].[Applications] INNER JOIN
                      CasinoLayout.UserGroup_Application ON [GeneralPurpose].[Applications].ApplicationID = CasinoLayout.UserGroup_Application.ApplicationID INNER JOIN
                      CasinoLayout.UserGroup_User ON CasinoLayout.UserGroup_Application.UserGroupID = CasinoLayout.UserGroup_User.UserGroupID INNER JOIN
                      CasinoLayout.UserGroups ON CasinoLayout.UserGroup_Application.UserGroupID = CasinoLayout.UserGroups.UserGroupID AND 
                      CasinoLayout.UserGroup_User.UserGroupID = CasinoLayout.UserGroups.UserGroupID INNER JOIN
                      CasinoLayout.Users ON CasinoLayout.UserGroup_User.UserID = CasinoLayout.Users.UserID
WHERE   (
	CasinoLayout.Users.BeginDate < GETUTCDATE() 
	AND (CasinoLayout.Users.EndDate IS NULL OR CasinoLayout.Users.EndDate > GETUTCDATE())
	)







GO
