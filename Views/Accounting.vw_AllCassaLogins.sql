SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllCassaLogins]
WITH SCHEMABINDING
AS
SELECT  
	so.Tag,
	so.LifeCycleID,	
	so.GamingDate,
	so.CloseTimeUTC,
	so.CloseTime,
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
FROM  [Accounting].[vw_AllStockOwners] so 
	INNER JOIN FloorActivity.tbl_UserAccesses UA ON (UA.UserID = so.FirstOwner or UA.UserID = so.OtherOwner) 
	--where login falls in that GamingDate time (11:00 to 7:00 next day)
	AND UA.LoginDate  >= DATEADD(hh, 6, so.GamingDate) 
	AND UA.LoginDate  <= DATEADD(hh,30, so.GamingDate) 
	INNER JOIN CasinoLayout.Users U ON U.UserID = UA.UserID
	INNER JOIN CasinoLayout.Sites ST ON ST.SiteID = UA.SiteID
where so.StockTypeID in(4,7) --only cassa and main cassa
	AND UA.ApplicationID in (70195,250445) --interest only in cassa or main cassa application
	and UA.SiteID in (1,2,3,4,5,6,7,8,43,71) --interest only in cassa sites
GO
