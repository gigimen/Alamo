SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_DeleteSlotTransaction]
@slottransID INT,
@UserAccessID INT
AS



--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specifie',16,1,@UserAccessID)
	RETURN 1
END



IF NOT EXISTS 
	(
	SELECT [SlotTransactionID] FROM [Accounting].[tbl_SlotTransactions]
		WHERE [SlotTransactionID] = @slottransID
		AND CancelID IS NULL
	)
BEGIN
	RAISERROR('Invalid SlotTransactionID (%d) specified or already cancelled',16,1,@slottransID)
	RETURN 1
END


DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_DeleteSlotTransaction

BEGIN TRY  


	--first create a new TransactionCancelID 
	INSERT INTO FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GETUTCDATE(),@UserAccessID)

	DECLARE @cancID INT
	SET @cancID = SCOPE_IDENTITY()
	--update the transaction
	UPDATE [Accounting].[tbl_SlotTransactions]
		SET CancelID = @cancID
		WHERE [SlotTransactionID] = @slottransID


	DECLARE @attr VARCHAR(256)
	SELECT @attr = 'TransID=''' + CAST([SlotTransactionID] AS VARCHAR(16)) + 
			''' OpTypeID=''' + CAST([OpTypeID] AS VARCHAR(16)) +  
			''' SlotNr=''' + CAST([SlotNr] AS VARCHAR(16)) + ''''
	FROM [Accounting].[tbl_SlotTransactions]
	WHERE [SlotTransactionID] = @slottransID
	EXECUTE [GeneralPurpose].[usp_BroadcastMessage] 'DeleteSlotTrans',@attr


	COMMIT TRANSACTION trn_DeleteSlotTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteSlotTransaction
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret	

GO
GRANT EXECUTE ON  [Accounting].[usp_DeleteSlotTransaction] TO [TecRole]
GO
