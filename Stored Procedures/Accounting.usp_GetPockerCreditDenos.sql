SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_GetPockerCreditDenos] 
@gamingdate			DATETIME,
@StockID			INT		 
AS

DECLARE
@ret				INT,
@minFillID			INT,
@count				INT

set @ret = 0

--look for transactionID of last
SELECT @minFillID = MIN(t.TransactionID),@count = COUNT(t.TransactionID)
FROM [Accounting].[tbl_PockerFillsCredits] p 
inner JOIN Accounting.tbl_Transactions t ON p.[FK_FillTransID] = t.TransactionID
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = t.SourceLifeCycleID
WHERE t.OpTypeID = 1 
AND lf.StockID = @StockID 
AND p.[FK_CreditTransID] IS NULL 
AND t.TrCancelID IS NULL

IF @count > 2
BEGIN
 	raiserror('Il tavolo ha piu di 2 consegne pendenti',16,1)
	return(1)   
END


SELECT [SourceTag]
      ,[SourceStockID]
      ,[SourceStockTypeID]
      ,[SourceLifeCycleID]
      ,[SourceGamingDate]
      ,[SourceTimeUTC]
      ,[SourceTimeLoc]
      ,[DestStockTag]
      ,[DestGamingDate]
      ,[DestStockID]
      ,[DestStockTypeID]
      ,[DestLifeCycleID]
      ,[DestUserAccessID]
      ,[DestUserID]
      ,[DestUserGroupID]
      ,[OpTypeID]
      ,[OperationName]
      ,[TransactionID]
      ,[SourceUserAccessID]
      ,[SourceUserID]
      ,[SourceUserGroupID]
      ,[TRCancelID]
      ,[DestTimeUTC]
      ,[DestTimeLoc]
      ,[Quantity]
      ,[ExchangeRate]
      ,[CashInbound]
      ,[ValueTypeName]
      ,[CurrencyID]
      ,[CurrencyAcronim]
      ,[DenoName]
      ,[FDescription]
      ,[IsFisical]
      ,[Denomination]
      ,[DenoID]
      ,[ValueTypeID]
      ,[WeightForSource]
      ,[WeightForDest]
  FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE TransactionID = @minFillID



RETURN @ret
GO
