SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllCassaLoginsNew]
WITH SCHEMABINDING
AS
SELECT  
	so.Tag,
	so.LifeCycleID,	
	so.GamingDate,
	so.CloseTimeUTC,
	so.CloseTime,
	so.KioskID,
	u.loginName,
	u.FirstName + ' ' + u.LastName 	AS Cassiera,
	ST.ComputerName as Location,
	UA.UserAccessID,
	UA.SiteID,
	UA.LoginDate as LoginDateUTC,
	UA.LogoutDate AS LogoutDateUTC,
	GeneralPurpose.fn_UTCToLocal(1,UA.LoginDate) AS LoginDate, 
	GeneralPurpose.fn_UTCToLocal(1,UA.LogoutDate) AS LogoutDate, 
	ST.CashlessTerminal,
	ST.FName AS SiteName
FROM  [Accounting].[vw_AllStockLifeCycles] so 
	INNER JOIN FloorActivity.tbl_UserAccesses UA ON UA.LifeCycleID = so.LifeCycleID 
	INNER JOIN CasinoLayout.Users U ON U.UserID = UA.UserID
	INNER JOIN CasinoLayout.Sites ST ON ST.SiteID = UA.SiteID	
where so.StockTypeID in(4,7) --only cassa and main cassa
	AND UA.ApplicationID in (70195,250445) --interest only in cassa or main cassa application
	and ST.SiteTypeID = 2 --interest only in cassa sites
GO
