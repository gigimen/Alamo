SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO




CREATE  PROCEDURE [Snoopy].[usp_UpdateGreenPass] 
@CustID		INT,
@scadenza			DATETIME
AS

IF @CustID IS NULL  OR NOT EXISTS (SELECT CustomerID FROM Snoopy.tbl_Customers WHERE CustomerID = @CustID AND CustCancelID IS null)
BEGIN
	RAISERROR('Invalid CustomerID specified',16,1,@CustID)
	RETURN (1)
END

IF @scadenza IS NULL OR @scadenza < GeneralPurpose.fn_GetGamingDate(GETDATE(),0,11)
BEGIN
	RAISERROR('Invalid Scadenza specified',16,1,@CustID)
	RETURN (1)
END

DECLARE  @ret			INT
BEGIN TRANSACTION trn_UpdateGreenPass

SET @ret = 0
BEGIN TRY  

	IF NOT EXISTS (SELECT * FROM [Snoopy].[tbl_GreenPass] WHERE CustomerID = @CustID)

		INSERT INTO [Snoopy].[tbl_GreenPass]
				   ([CustomerID]
				   ,[Scadenza])
			 VALUES
				   (@CustID
				   ,@scadenza)
	ELSE

		UPDATE [Snoopy].[tbl_GreenPass]
		   SET  [Scadenza] = @scadenza
		 WHERE [CustomerID] = @CustID

	COMMIT TRANSACTION trn_UpdateGreenPass


END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateGreenPass	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH


RETURN @ret


GO
