SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Snoopy].[usp_DeleteTorneoPokerCashMov]
@MoveID INT,
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
	SELECT [PK_MovID] FROM [Snoopy].[tbl_PokerTorneoCashMov]
		WHERE [PK_MovID] = @MoveID
		AND CancelID IS NULL
	)
BEGIN
	RAISERROR('Invalid [PK_MovID] (%d) specified or already cancelled',16,1,@MoveID)
	RETURN 1
END


DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_DeleteTorneoPokerCashMov

BEGIN TRY  


	--first create a new TransactionCancelID 
	INSERT INTO FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GETUTCDATE(),@UserAccessID)

	DECLARE @cancID INT
	SET @cancID = SCOPE_IDENTITY()
	--update the transaction
	UPDATE [Snoopy].[tbl_PokerTorneoCashMov]
		SET CancelID = @cancID
		WHERE [PK_MovID] = @MoveID


	DECLARE @attr VARCHAR(256)
	SELECT @attr = 'TransID=''' + CAST([PK_MovID] AS VARCHAR(16)) + 
			''' OpTypeID=''' + CAST([MoveType] AS VARCHAR(16)) + ''''
	FROM [Snoopy].[tbl_PokerTorneoCashMov]
	WHERE [PK_MovID] = @MoveID
	EXECUTE [GeneralPurpose].[usp_BroadcastMessage] 'DeleteTPCashMov',@attr


	COMMIT TRANSACTION trn_DeleteTorneoPokerCashMov

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteTorneoPokerCashMov
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret	

GO
