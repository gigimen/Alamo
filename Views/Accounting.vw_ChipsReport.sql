SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_ChipsReport]
WITH SCHEMABINDING
AS
select 	 Accounting.vw_LiveGameStockStatus.Tag,
       	 Accounting.vw_LiveGameStockStatus.CloseGamingDate as GamingDate ,
	C10000.Quantity as Chips10000,
	C5000.Quantity as Chips5000,
	C1000.Quantity as Chips1000,
	C100.Quantity as Chips100,
	C50.Quantity as Chips50,
	C20.Quantity as Chips20,
	C10.Quantity as Chips10,
	C5.Quantity as Chips5,
	C1.Quantity as Chips1,
	IsNull(C10000.Quantity,0) * 10000 +
	IsNull(C5000.Quantity ,0) * 5000 +
	IsNull(C1000.Quantity ,0) * 1000 +
	IsNull(C100.Quantity  ,0) * 100 +
	IsNull(C50.Quantity   ,0) * 50 +
	IsNull(C20.Quantity   ,0) * 20 +
	IsNull(C10.Quantity   ,0) * 10 +
	IsNull(C5.Quantity    ,0) * 5 +
	IsNull(C1.Quantity,0) as TotalValue,
	IsNull(edrop.Quantity,0) * 100 as EstimatedDrop
from  Accounting.vw_LiveGameStockStatus
left outer join Accounting.vw_AllSnapshotDenominations C10000
on C10000.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C10000.DenoID = 1
left outer join Accounting.vw_AllSnapshotDenominations C5000
on C5000.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C5000.DenoID = 2
left outer join Accounting.vw_AllSnapshotDenominations C1000
on C1000.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C1000.DenoID = 3
left outer join Accounting.vw_AllSnapshotDenominations C100
on C100.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C100.DenoID = 4
left outer join Accounting.vw_AllSnapshotDenominations C50
on C50.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C50.DenoID = 5
left outer join Accounting.vw_AllSnapshotDenominations C20
on C20.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C20.DenoID = 6
left outer join Accounting.vw_AllSnapshotDenominations C10
on C10.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C10.DenoID = 7
left outer join Accounting.vw_AllSnapshotDenominations C5
on C5.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C5.DenoID = 8
left outer join Accounting.vw_AllSnapshotDenominations C1
on C1.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and C1.DenoID = 9
left outer join Accounting.vw_AllSnapshotDenominations edrop
on edrop.LifeCycleSnapshotID = Accounting.vw_LiveGameStockStatus.CloseSnapshotID and edrop.DenoID = 13
GO
