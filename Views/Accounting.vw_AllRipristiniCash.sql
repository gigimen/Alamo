SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllRipristiniCash]
WITH SCHEMABINDING
AS
/*

select * from [Accounting].[vw_AllRipristiniCash]
where GamingDate = '7.1.2019' and StockTypeID in (4,7)

*/
SELECT 
GamingDate  ,
Tag			,
StockID		,
StockTypeID	,
LifeCycleID	,
CurrencyID,
Acronim,
Sum(Total)	as TotCash
from [Accounting].[vw_AllRipristini] 
where ValueTypeID in(2,3,7)
--and GamingDate = '7.1.2019'
group by GamingDate,
Tag			,
StockID		,
StockTypeID	,
CurrencyID,
Acronim,
LifeCycleID
GO
