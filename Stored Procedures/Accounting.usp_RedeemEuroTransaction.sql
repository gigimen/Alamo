SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Accounting].[usp_RedeemEuroTransaction]
@RedemptionTransID	int, -- a redemption transaction ID
@AcquistoTransID int -- acquisto to be redeemed
AS



--first some check on parameters

--the specified transaction must exists and must be of type 12 (redemption)
if not exists (select TransactionID from Accounting.tbl_EuroTransactions where TransactionID = @RedemptionTransID and OpTypeID = 12)
begin
	raiserror('Invalid Redemption TransactionID (%d) specified or transcation of the wrong type',16,1,@RedemptionTransID)
	return 1
end

--the specified transaction must exists and must be of type 11 (acquisto)
if not exists (select TransactionID from Accounting.tbl_EuroTransactions where TransactionID = @AcquistoTransID and OpTypeID = 11)
begin
	raiserror('Invalid Acquisto TransactionID (%d) specified or transcation of the wrong type',16,1,@AcquistoTransID)
	return 1
end

--make sure the acquisto transation has no been redeemed yet unless is the same transaction
if exists (
	select TransactionID 
	from Accounting.tbl_EuroTransactions 
	where TransactionId = @AcquistoTransID 
	and RedeemTransactionID is not null 
	and RedeemTransactionID <> @RedemptionTransID
	)
begin
	raiserror('Specified Acquisto TransactionID (%d) has been already redeemed by another transaction!!!',16,1,@AcquistoTransID)
	return 1
end
	
DECLARE @ret INT
BEGIN TRANSACTION trn_RedeemEuroTransaction

BEGIN TRY  

	update Accounting.tbl_EuroTransactions
		set RedeemTransactionID	= @RedemptionTransID
	where TransactionID = @AcquistoTransID



	COMMIT TRANSACTION trn_RedeemEuroTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RedeemEuroTransaction		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	return @ret
END CATCH

return 0
GO
