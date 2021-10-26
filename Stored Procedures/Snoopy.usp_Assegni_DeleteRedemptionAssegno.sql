SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Snoopy].[usp_Assegni_DeleteRedemptionAssegno]
@AssegnoID INT,
@UserAccessID INT
AS





--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specifie',16,1,@UserAccessID)
	RETURN 1
END


declare @RedeemCustTransID INT

SELECT @RedeemCustTransID = FK_RedemCustTransID 
FROM Snoopy.tbl_Assegni 
WHERE PK_AssegnoID = @AssegnoID

IF @RedeemCustTransID IS NULL
BEGIN
	RAISERROR('Wrong Assegno %d specified',16,1,@AssegnoID)
	RETURN 1
END

DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_DeleteRedemptionAssegno

BEGIN TRY  


	--first create a new CustTrCancelID 
	INSERT INTO FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GETUTCDATE(),@UserAccessID)

	DECLARE @cancID INT
	SET @cancID = @@IDENTITY
	
	--update the Chiusura snapshot
	UPDATE Snoopy.tbl_CustomerTransactions
		SET CustTrCancelID = @cancID
		WHERE CustomerTransactionID = @RedeemCustTransID

	--update also assegni table
	UPDATE Snoopy.tbl_Assegni 
	SET FK_RedemCustTransID = NULL
	WHERE PK_AssegnoID = @AssegnoID


	COMMIT TRANSACTION trn_DeleteRedemptionAssegno

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteRedemptionAssegno
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
