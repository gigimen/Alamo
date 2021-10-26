SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [FloorActivity].[vw_AllLogins]
WITH SCHEMABINDING
AS
SELECT  CasinoLayout.Users.LastName, 
		CasinoLayout.Users.FirstName, 
		GeneralPurpose.fn_UTCToLocal(1,FloorActivity.tbl_UserAccesses.LoginDate) as LoginDate, 
		GeneralPurpose.fn_UTCToLocal(1,FloorActivity.tbl_UserAccesses.LogoutDate) as LogoutDate, 
		CasinoLayout.Sites.FName AS From_Computer, 
        [GeneralPurpose].[Applications].FName AS [Using]
FROM    FloorActivity.tbl_UserAccesses INNER JOIN
CasinoLayout.Users ON CasinoLayout.Users.UserID = FloorActivity.tbl_UserAccesses.UserID INNER JOIN
CasinoLayout.Sites ON CasinoLayout.Sites.SiteID = FloorActivity.tbl_UserAccesses.SiteID INNER JOIN
[GeneralPurpose].[Applications] ON [GeneralPurpose].[Applications].ApplicationID = FloorActivity.tbl_UserAccesses.ApplicationID







GO
