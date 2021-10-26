SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_LiveGameStockStatus]
WITH SCHEMABINDING
AS
SELECT  TOP 100 PERCENT 
	CasinoLayout.Stocks.Tag,
	CasinoLayout.Stocks.FName,
	CasinoLayout.Stocks.StockTypeID,
	CasinoLayout.Stocks.StockID,
	LOSS.LastOpenGamingDate		AS OpenGamingDate,
	LCSS.LastCloseGamingDate	AS CloseGamingDate,
	LCS.LifeCycleID  		AS CloseLifeCycleID, 
	LCS.LifeCycleSnapshotID  	AS CloseSnapshotID, 
	LCS.SnapshotTimeLoc 		AS CloseTime, 
	LOS.LifeCycleID  		AS OpenLifeCycleID, 
	LOS.LifeCycleSnapshotID		AS OpenSnapshotID, 
	LOS.SnapshotTimeLoc		AS OpenTime,
	CONTR.TransactionID		AS ConsegnaTransactionID,
	CONTR.DestLifeCycleID		AS AccepterLifeCycleID
from CasinoLayout.Stocks
--go first with last close
inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots LCS
on CasinoLayout.Stocks.StockID = LCS.StockID
--inner join Accounting.vw_AllUserAccesses UAC
--on UAC.UserAccessID = LCS.UserAccessID
--join per StockID and last known close snapshot for each stock
inner join (
	select StockID,max(GamingDate) as LastCloseGamingDate 
	from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
	where SS.SnapshotTypeID = 3 --Chiusura snapshottype
	and (SS.StockTypeID in(1,3))   --table and SMT
	group by StockID
) as LCSS
on LCS.StockID = LCSS.StockID 
and LCS.GamingDate = LCSS.LastCloseGamingDate 
and LCS.SnapshotTypeID = 3 --Chiusura snapshottype
--then go with last open
inner join Accounting.vw_AllLifeCycleNonCancelledSnapshots LOS
on CasinoLayout.Stocks.StockID = LOS.StockID
--inner join Accounting.vw_AllUserAccesses UAO
--on UAO.UserAccessID = LOS.UserAccessID
--join per StockID and last known open snapshot for each stock
inner join (
	select StockID,max(GamingDate) as LastOpenGamingDate 
	from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
	where SS.SnapshotTypeID = 1 --apertura snapshottype
	and (SS.StockTypeID in(1,3))  --table and SMT
	group by StockID
) as LOSS
on LOS.StockID = LOSS.StockID 
and LOS.GamingDate = LOSS.LastOpenGamingDate 
and LOS.SnapshotTypeID = 1 --apertura snapshottype
left outer join Accounting.vw_AllTransactions CONTR
on CONTR.SourceLifeCycleID = LCS.LifeCycleID and CONTR.OpTypeID = 6



Where CasinoLayout.Stocks.StockTypeID in(1,3) --table and SMT
order by CasinoLayout.Stocks.StockTypeID,CasinoLayout.Stocks.StockID
GO
