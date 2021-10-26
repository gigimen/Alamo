SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Snoopy].[usp_Bonifici_DeleteBonifico]
@BonificoID INT,
@UserAccessID INT
AS


--first some check on parameters
IF NOT EXISTS (SELECT UserAccessID FROM FloorActivity.tbl_UserAccesses WHERE UserAccessID = @UserAccessID)
BEGIN
	RAISERROR('Invalid UserAccessID (%d) specified',16,1,@UserAccessID)
	RETURN 1
END

IF NOT EXISTS (SELECT BonificoID FROM Snoopy.tbl_Bonifici WHERE BonificoID = @BonificoID)
BEGIN
	RAISERROR('Invalid BonificoID (%d) specified',16,1,@BonificoID)
	RETURN 2
END


DECLARE @CustTransID INT

SELECT @CustTransID = OrderCustTransID 
		FROM Snoopy.tbl_Bonifici 
		WHERE BonificoID = @BonificoID

IF @CustTransID IS NULL
BEGIN
	RAISERROR('Wrong Bonifico %d specified',16,1,@BonificoID)
	RETURN 1
END



DECLARE @RC INT

EXECUTE @RC = [Snoopy].[usp_DeleteCustomerTransaction] @CustTransID,@UserAccessID

RETURN @RC

GO
