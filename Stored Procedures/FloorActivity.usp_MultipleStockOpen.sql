SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*
	this is a check to make sure that there are no multiple open life cycles on the same stock
*/
CREATE PROCEDURE  [FloorActivity].[usp_MultipleStockOpen]
AS
select 	CasinoLayout.Stocks.StockID,
	CasinoLayout.Stocks.FName, 
	Apertura.LifeCycleSnapshotID,
	count(*) as num
from CasinoLayout.Stocks 
	inner join Accounting.tbl_LifeCycles 
	on CasinoLayout.Stocks.StockID = Accounting.tbl_LifeCycles.StockID
	INNER JOIN Accounting.tbl_Snapshots Apertura 
	ON Apertura.LifeCycleID = Accounting.tbl_LifeCycles.LifeCycleID and 
	Apertura.SnapshotTypeID in (select SnapshotTypeID from CasinoLayout.SnapshotTypes where FName = 'Apertura')
	--snapshot has not been cancelled
	AND Apertura.LCSnapShotCancelID IS NULL
group by CasinoLayout.Stocks.StockID,CasinoLayout.Stocks.FName,Apertura.LifeCycleSnapshotID
HAVING COUNT(*) > 1
GO
