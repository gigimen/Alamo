SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllRipristini]
WITH SCHEMABINDING
AS


/*

select DestSta from [Accounting].[vw_AllRipristini] where GamingDate = '7.1.2019'
*/
SELECT 
DestStockTag		AS Tag,
DestStockID			AS StockID		,
DestStockTypeID		AS StockTypeID	,
DestLifeCycleID		AS LifeCycleID	,
TransactionID,
SourceGamingDate AS GamingDate,
CurrencyAcronim AS Acronim,
CurrencyID,
ValueTypeID,
ValueTypeName,
SUM(Quantity*Denomination) AS Total

FROM Accounting.vw_AllTransactionDenominations
WHERE OpTypeID = 5 --only ripristino operations
GROUP BY DestStockTag,
DestStockID,
DestStockTypeID,
DestLifeCycleID,
TransactionID,
SourceTag,
SourceGamingDate,
CurrencyAcronim,
CurrencyID,
ValueTypeID,
ValueTypeName
GO
