SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [Accounting].[fn_GetLastGamingDate] (@StockID int , @bCloseOnly int,@fromDate datetime)
RETURNS datetime 
WITH SCHEMABINDING
AS  
BEGIN 
declare @LastGamingDate datetime
if(@bCloseOnly is null or @bCloseOnly = 0)
begin
--look also for open life cycles
	if @fromDate is null
		SELECT    @LastGamingDate = MAX(GamingDate)
	        	FROM          Accounting.tbl_LifeCycles
			INNER JOIN Accounting.tbl_Snapshots 
			--get only those life cycles for which there is a Apertura snapshot
			on Accounting.tbl_Snapshots.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
			and Accounting.tbl_Snapshots.SnapshotTypeID = 1  --APERTURA
			AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
			WHERE      (Accounting.tbl_LifeCycles.StockID = @StockID ) 
	else
		SELECT    @LastGamingDate = MAX(GamingDate)
	        	FROM          Accounting.tbl_LifeCycles
			--get only those life cycles for which there is a Apertura snapshot
			INNER JOIN Accounting.tbl_Snapshots
			ON Accounting.tbl_Snapshots.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
			and Accounting.tbl_Snapshots.SnapshotTypeID = 1 --APERTURA
			AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
			WHERE      (Accounting.tbl_LifeCycles.StockID = @StockID ) 
			AND (Accounting.tbl_LifeCycles.GamingDate <= @fromDate) 
end
else
begin
--ignore life cycles that are open
	if @fromDate is null
		SELECT    @LastGamingDate = MAX(GamingDate)
	        	FROM          Accounting.tbl_LifeCycles
			INNER JOIN Accounting.tbl_Snapshots 
			--get only those life cycles for which there is a Chiusura snapshot
			ON Accounting.tbl_Snapshots.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
			and Accounting.tbl_Snapshots.SnapshotTypeID = 3 --Chiusura
			AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
			WHERE      (Accounting.tbl_LifeCycles.StockID = @StockID ) 
	else
		SELECT    @LastGamingDate = MAX(GamingDate)
	        	FROM          Accounting.tbl_LifeCycles
			INNER JOIN Accounting.tbl_Snapshots 
			--get only those life cycles for which there is a Chiusura snapshot
			ON Accounting.tbl_Snapshots.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID
			and Accounting.tbl_Snapshots.SnapshotTypeID = 3 --Chiusura
			AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
			WHERE      (Accounting.tbl_LifeCycles.StockID = @StockID ) 
			AND (Accounting.tbl_LifeCycles.GamingDate <= @fromDate) 
end
	return @LastGamingDate
END
GO
