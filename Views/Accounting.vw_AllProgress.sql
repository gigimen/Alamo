SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllProgress]
WITH SCHEMABINDING
AS
SELECT TOP 100 PERCENT
	st.Tag,
	st.StockID,
	lf.LifeCycleID,
	lf.GamingDate,
	den.FDescription,
	p.DenoID,
	p.StateTime as StateTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,p.StateTime) as StateTimeLoc,
	p.Quantity,
	p.Quantity * den.Denomination as Value,
	CasinoLayout.Sites.ComputerName,
    GeneralPurpose.fn_UTCToLocal(1,UA.LoginDate) as LoginDate,
	GeneralPurpose.fn_UTCToLocal(1,UA.LogoutDate) as LogoutDate
FROM    Accounting.tbl_Progress p
INNER JOIN Accounting.tbl_LifeCycles lf ON p.LifeCycleID = lf.LifeCycleID 
INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID 
INNER JOIN CasinoLayout.tbl_Denominations den ON p.DenoID = den.DenoID
INNER JOIN FloorActivity.tbl_UserAccesses UA ON p.UserAccessID = UA.UserAccessID 
INNER JOIN CasinoLayout.Sites ON CasinoLayout.Sites.SiteID = UA.SiteID 
order by StateTime






GO
