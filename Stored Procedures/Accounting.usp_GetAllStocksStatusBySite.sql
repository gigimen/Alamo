SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_GetAllStocksStatusBySite] 
@StockTypeID int,
@gaming datetime,
@siteID int,
@appID int
AS

declare @today datetime
set @today = GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				@StockTypeID)
if @gaming is null
BEGIN
	--we always have to specify the gaming date 
	--otherwise we have troubles getting the previous close gaming date
	RAISERROR('Specify a valid Gaming Date',16,1)
	RETURN (1)
END

if @StockTypeID is null or not exists (select StockTypeID from CasinoLayout.StockTypes where StockTypeID = @StockTypeID)
BEGIN
	RAISERROR('Specify a valid StockTypeID',16,1)
	RETURN (1)
END
if @siteID is null or not exists (select SiteID FROM CasinoLayout.Sites where SiteID = @siteID)
BEGIN
	RAISERROR('Specify a valid SiteID',16,1)
	RETURN (1)
END
if @appID is null or not exists (select ApplicationID from [GeneralPurpose].[Applications] where ApplicationID = @appID)
BEGIN
	RAISERROR('Specify a valid ApplicationID',16,1)
	RETURN (1)
END

SELECT  clo.Tag as Tag,
	opn.GamingDate		AS OpenGamingDate,
	clo.GamingDate		AS CloseGamingDate,
	clo.FName,
	clo.StockTypeID,
	clo.StockID,
	clo.MinBet,
	clo.InitialReserve,
	clo.LifeCycleID  		AS CloseLifeCycleID, 
	clo.LifeCycleSnapshotID  	AS CloseSnapshotID, 
	clo.SnapshotTimeLoc 		AS CloseTimeLoc, 
	clo.SnapshotTime 		AS CloseTimeUTC, 
	opn.LifeCycleID  		AS OpenLifeCycleID, 
	opn.LifeCycleSnapshotID		AS OpenSnapshotID, 
	opn.SnapshotTimeLoc		AS OpenTimeLoc,
	opn.SnapshotTime		AS OpenTimeUTC,
	case opn.GamingDate
		when @today
		then 1
	else 0
	end as IsToday,
	case when opn.GamingDate > clo.GamingDate then 1
		else 0
	end  as IsStockOpen
FROM	
(
select
	s.Tag,
	s.FName,
	s.StockTypeID,
	s.StockID,
	s.MinBet,
	ISNULL(ris.Totale,0) AS InitialReserve,
	l.GamingDate,
	l.LifeCycleID, 
	ss.LifeCycleSnapshotID, 
	ss.SnapshotTimeLoc , 
	ss.SnapshotTime
from
	Accounting.tbl_Snapshots ss
	INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
	INNER JOIN CasinoLayout.Site_App_Stock sas ON sas.StockID = s.StockID
	inner join 
	(
		select s.StockID,max(ss.LifeCycleID) as LastCloseLFID 
		FROM	Accounting.tbl_Snapshots ss
		INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
		INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
		WHERE   (ss.LCSnapShotCancelID IS NULL) 
		and  ss.SnapshotTypeID = 3 
		and s.StockTypeID = @StockTypeID 
		and l.GamingDate <= @gaming
		group by s.StockID
	) lc on lc.StockId = s.StockID and l.LifeCycleID = lc.LastCloseLFID
	LEFT OUTER JOIN [CasinoLayout].[vw_AllStockRiservaTotals] ris ON s.StockId = ris.StockID
	where ss.LCSnapShotCancelID IS NULL	and  ss.SnapshotTypeID = 3 
	and sas.SiteId = @siteID and sas.ApplicationID = @appID 
) clo
inner join 
(
select
	s.FName,
	s.StockTypeID,
	s.StockID,
	s.MinBet,
	l.GamingDate,
	l.LifeCycleID, 
	ss.LifeCycleSnapshotID, 
	ss.SnapshotTimeLoc , 
	ss.SnapshotTime
from
	Accounting.tbl_Snapshots ss
	INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
	INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
	INNER JOIN CasinoLayout.Site_App_Stock sas ON sas.StockID = s.StockID
	inner join 
	(
		select s.StockID,max(ss.LifeCycleID) as LastCloseLFID 
		FROM	Accounting.tbl_Snapshots ss
		INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
		INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
		WHERE   (ss.LCSnapShotCancelID IS NULL) 
		and  ss.SnapshotTypeID = 1 
		and s.StockTypeID = @StockTypeID 
		and l.GamingDate <= @gaming
		group by s.StockID
	) lc on lc.StockId = s.StockID and l.LifeCycleID = lc.LastCloseLFID
	where ss.LCSnapShotCancelID IS NULL	and  ss.SnapshotTypeID = 1 
	and sas.SiteId = @siteID and sas.ApplicationID = @appID 
) opn on opn.StockID = clo.StockID
order by  clo.StockID
GO
