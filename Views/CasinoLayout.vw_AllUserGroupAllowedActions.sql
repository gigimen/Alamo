SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [CasinoLayout].[vw_AllUserGroupAllowedActions]
WITH SCHEMABINDING
AS
SELECT  CasinoLayout.UserGroups.UserGroupID, 
	CasinoLayout.UserGroups.FName AS UserGroupName, 
        CasinoLayout.UserGroup_Application.AllowedActions, 
	CasinoLayout.UserGroup_Application.ApplicationID, 
	[GeneralPurpose].[Applications].FName AS ApplicationName
FROM    [GeneralPurpose].[Applications] 
INNER JOIN CasinoLayout.UserGroup_Application ON [GeneralPurpose].[Applications].ApplicationID = CasinoLayout.UserGroup_Application.ApplicationID 
INNER JOIN CasinoLayout.UserGroups ON CasinoLayout.UserGroup_Application.UserGroupID = CasinoLayout.UserGroups.UserGroupID 







GO
