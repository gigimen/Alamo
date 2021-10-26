SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Snoopy].[usp_Assegni_DeleteIncassoAssegno]
@AssegnoID INT,
@UserAccessID INT
AS


--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specifie',16,1,@UserAccessID)
	RETURN 1
END

declare @CustTransID INT

SELECT @CustTransID = EmissCustTransID 
	FROM Snoopy.vw_AllAssegniEx 
	WHERE AssegnoID = @AssegnoID

IF @CustTransID IS NULL
BEGIN
	RAISERROR('Wrong Assegno %d specified',16,1,@AssegnoID)
	RETURN 1
END


DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_DeleteAssegnoIncassoEx

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
		WHERE CustomerTransactionID = @CustTransID
		
	

	COMMIT TRANSACTION trn_DeleteAssegnoIncassoEx

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteAssegnoIncassoEx
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
