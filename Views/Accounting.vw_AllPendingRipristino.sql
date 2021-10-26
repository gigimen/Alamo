SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_AllPendingRipristino]
WITH SCHEMABINDING
AS
select top 100 percent
DestStockTag,
TransactionID,
TotalForSource as Total,
SourceTag,
SourceGamingDate 
from Accounting.vw_AllTransactions 
	where OpTypeID = 5 --only ripristino operations
	-- transaction is pending if DestLifeCycleID is null
	and  DestLifeCycleID is null
order by DestStockID
GO
