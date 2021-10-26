SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_DeleteMovimentoGettoniGioco] 
@TransactionID		INT
AS



DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_MovimentiGettoniGiocoEuro

BEGIN TRY  


	DELETE FROM Accounting.tbl_MovimentiGettoniGiocoEuro
	WHERE TransactionID = @TransactionID


	COMMIT TRANSACTION trn_MovimentiGettoniGiocoEuro

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_MovimentiGettoniGiocoEuro
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret


GO
