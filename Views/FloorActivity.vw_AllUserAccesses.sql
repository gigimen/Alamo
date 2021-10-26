SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [FloorActivity].[vw_AllUserAccesses]
WITH SCHEMABINDING
AS
SELECT  
	FloorActivity.tbl_UserAccesses.UserAccessID,
	CasinoLayout.Users.FirstName + ' ' + CasinoLayout.Users.LastName As UserName,
	CasinoLayout.Users.UserID, 
	CasinoLayout.Users.LoginName,
	FloorActivity.tbl_UserAccesses.UserGroupID, 
	GeneralPurpose.fn_UTCToLocal(1,FloorActivity.tbl_UserAccesses.LoginDate) as LoginDate, 
	GeneralPurpose.fn_UTCToLocal(1,FloorActivity.tbl_UserAccesses.LogoutDate) as LogoutDate, 
	FloorActivity.tbl_UserAccesses.LogoutForced, 
	CasinoLayout.Sites.SiteID,
	CasinoLayout.Sites.ComputerName,
	CasinoLayout.Sites.FName as SiteName,
	[GeneralPurpose].[Applications].ApplicationID,
    [GeneralPurpose].[Applications].FName AS Application
FROM    FloorActivity.tbl_UserAccesses 
	INNER JOIN  CasinoLayout.Sites
	ON CasinoLayout.Sites.SiteID = FloorActivity.tbl_UserAccesses.SiteID 
	INNER JOIN CasinoLayout.Users 
	ON FloorActivity.tbl_UserAccesses.UserID = CasinoLayout.Users.UserID 
	INNER JOIN [GeneralPurpose].[Applications] 
	ON FloorActivity.tbl_UserAccesses.ApplicationID = [GeneralPurpose].[Applications].ApplicationID




GO
