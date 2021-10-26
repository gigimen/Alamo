SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [Accounting].[usp_GetDailySlotTransactionMovementEx]
@currencyID INT,
@optypeid INT,
@lfid INT,
@totCount INT OUTPUT,
@totAmountCents INT OUTPUT
AS

IF @optypeid NOT IN (-1,15,16,17)
BEGIN
	raiserror('invalid @opTypeID specified',16,1)
	return(1)	
END

IF @optypeid = -1 --all operation types together
	SELECT @totCount = ISNULL(COUNT(*),0), @totAmountCents = ISNULL(SUM([AmountCents]),0) 
	FROM [Accounting].[vw_AllSlotTransactions]
	WHERE [LifeCycleID] = @lfid AND 
	(@currencyID=-1 OR (@currencyID = 0 AND IsSfr = 0) OR (@currencyID = 4 AND IsSfr = 1))
ELSE
	SELECT @totCount = ISNULL(COUNT(*),0), @totAmountCents = ISNULL(SUM([AmountCents]),0) 
	FROM [Accounting].[vw_AllSlotTransactions]
	WHERE [LifeCycleID] = @lfid AND OpTypeID = @optypeid AND 
	(@currencyID=-1 OR (@currencyID = 0 AND IsSfr = 0) OR (@currencyID = 4 AND IsSfr = 1))






GO
