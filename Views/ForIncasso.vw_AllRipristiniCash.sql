SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [ForIncasso].[vw_AllRipristiniCash]
WITH SCHEMABINDING
AS
/*

select * from [ForIncasso].[vw_AllRipristiniCash]
where GamingDate = '6.6.2020' and StockTypeID in (4,7)

*/
SELECT 
GamingDate  ,
Tag			,
StockID		,
StockTypeID	,
LifeCycleID	,
CurrencyID,
Acronim,
SUM(Total)	AS TotCash
FROM [Accounting].[vw_AllRipristini] 
WHERE ValueTypeID IN(2,3,7,40)
--and GamingDate = '7.1.2019'
GROUP BY GamingDate,
Tag			,
StockID		,
StockTypeID	,
CurrencyID,
Acronim,
LifeCycleID
GO
