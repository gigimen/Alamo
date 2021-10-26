SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_LastGamingDateLifeCycles]
WITH SCHEMABINDING
AS

select 
	StockID,
	StockTypeID,
	Tag,
	GamingDate,
	LifeCycleID,
	StockCompositionID,
	ChiusuraSnapshotID,
	CONTransactionID,
	ConsegnaDestLifeCycleID,
	RIPTransactionID
from [Accounting].[vw_AllChiusuraConsegnaRipristino]
where GamingDate =
(
--work one day behind same as mainstock
select max(GamingDate) from Accounting.tbl_LifeCycles where StockID = 31
)
GO
