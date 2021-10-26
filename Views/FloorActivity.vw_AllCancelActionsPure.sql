SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [FloorActivity].[vw_AllCancelActionsPure]
WITH SCHEMABINDING
AS
SELECT     
	FloorActivity.tbl_Cancellations.CancelID, 
	GeneralPurpose.fn_UTCToLocal(1, FloorActivity.tbl_Cancellations.CancelDate) AS CancelDate, 
    USOWN.LastName + ' ' + USOWN.FirstName AS UserName, 
	OWNSites.ComputerName
FROM         FloorActivity.tbl_Cancellations INNER JOIN
                      FloorActivity.tbl_UserAccesses UAOWN ON UAOWN.UserAccessID = FloorActivity.tbl_Cancellations.UserAccessID INNER JOIN
                      CasinoLayout.Users USOWN ON USOWN.UserID = UAOWN.UserID INNER JOIN
                      CasinoLayout.Sites OWNSites ON OWNSites.SiteID = UAOWN.SiteID




GO
