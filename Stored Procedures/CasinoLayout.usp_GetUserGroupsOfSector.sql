SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [CasinoLayout].[usp_GetUserGroupsOfSector]
	@UserID	int
AS
SELECT	CasinoLayout.UserGroups.FName UserGroupName,
		CasinoLayout.UserGroups.UserGroupID
FROM		CasinoLayout.UserGroups 
INNER JOIN	CasinoLayout.UserGroup_Sector UGS ON UGS.UserGroupID = CasinoLayout.UserGroups.UserGroupID 
INNER JOIN	CasinoLayout.UserGroup_Sector UGU ON UGU.SectorID = UGS.SectorID
INNER JOIN	CasinoLayout.UserGroup_User ON UGU.UserGroupID = CasinoLayout.UserGroup_User.UserGroupID 
					and CasinoLayout.UserGroup_User.UserID = @UserID

GO
