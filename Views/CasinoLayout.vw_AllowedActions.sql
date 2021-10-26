SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [CasinoLayout].[vw_AllowedActions]
WITH SCHEMABINDING
AS
SELECT  [GeneralPurpose].[Applications].ApplicationID, 
	[GeneralPurpose].[Applications].FName 		AS ApplicationName, 
	CasinoLayout.UserGroups.UserGroupID,
	CasinoLayout.UserGroups.FName 		AS GroupName, 
        CasinoLayout.UserGroup_Application.AllowedActions
FROM    [GeneralPurpose].[Applications] 
	INNER JOIN CasinoLayout.UserGroup_Application 
	ON [GeneralPurpose].[Applications].ApplicationID = CasinoLayout.UserGroup_Application.ApplicationID 
	INNER JOIN CasinoLayout.UserGroups 
	ON CasinoLayout.UserGroup_Application.UserGroupID = CasinoLayout.UserGroups.UserGroupID







GO
