SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW  [FloorActivity].[vw_AllCassaLoginsNew]
WITH SCHEMABINDING
AS
SELECT  
	so.Tag,
	so.LifeCycleID,
	so.StockID,	
	so.GamingDate,
	so.CloseTimeUTC,
	so.CloseTime,
	so.KioskID,
	u.loginName,
	u.FirstName + ' ' + u.LastName 	AS Cassiera,
	ST.ComputerName AS Location,
	ST.ComputerIP AS Computer2ndFloor,
	UA.UserAccessID,
	UA.SiteID,
	UA.LoginDate AS LoginDateUTC,
	UA.LogoutDate AS LogoutDateUTC,
	GeneralPurpose.fn_UTCToLocal(1,UA.LoginDate) AS LoginDate, 
	GeneralPurpose.fn_UTCToLocal(1,UA.LogoutDate) AS LogoutDate, 
	ST.CashlessTerminal,
	ST.FName AS SiteName
FROM  [Accounting].[vw_AllStockLifeCycles] so 
	INNER JOIN FloorActivity.tbl_UserAccesses UA ON UA.LifeCycleID = so.LifeCycleID 
	INNER JOIN CasinoLayout.Users U ON U.UserID = UA.UserID
	INNER JOIN CasinoLayout.Sites ST ON ST.SiteID = UA.SiteID
WHERE so.StockTypeID IN(4,7) --only cassa and main cassa
	AND UA.ApplicationID IN (70195,250445) --interest only in cassa or main cassa application
	AND ST.SiteTypeID = 1 --interest only in cassa sites
GO
