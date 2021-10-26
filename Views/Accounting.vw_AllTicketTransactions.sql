SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [Accounting].[vw_AllTicketTransactions]
WITH SCHEMABINDING
AS
SELECT  
	ts.[TicketTransID],
	ts.TicketNumber, 
	ts.[LifeCycleID], 
	ts.[AmountCents],
	CONVERT(FLOAT,ts.[AmountCents]) / 100.0 AS Importo,
	lf.GamingDate		AS GamingDate, 
	lf.Tag				AS Tag, 
	lf.StockID			AS StockID,
	GeneralPurpose.fn_UTCToLocal(1,ts.[TransTimeUTC]) AS TransTimeLoc,
	ts.IsVoided,
	ts.IsPromo,
	ts.IsSfr,
	ts.IsDRGT,
	GeneralPurpose.fn_UTCToLocal(1,ts.IssueTimeUTC) AS IssueTimeLoc,
	ts.IssueLocation,
	ts.FK_SiteID AS SiteID,
	st.SiteTypeID,
	st.FName AS RedeemSite
FROM    Accounting.tbl_TicketTransactions ts 
INNER JOIN Accounting.vw_AllStockLifeCycles lf ON ts.[LifeCycleID] = lf.LifeCycleID
INNER JOIN CasinoLayout.Sites st ON st.SiteID = ts.FK_SiteID
GO
