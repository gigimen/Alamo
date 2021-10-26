SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Managers].[msp_DeleteConteggio] 
@conteggioid INT
AS
PRINT 'Deleting @conteggioid ' +STR(@conteggioid)


declare @ret int
set @ret = 0
BEGIN TRANSACTION trn_DeleteConteggio

BEGIN TRY  

	DELETE FROM [FloorActivity].[tbl_ConteggioValuesModifications] WHERE ModId IN(
	SELECT ModiD FROM  [FloorActivity].[tbl_ConteggiModifications] WHERE ConteggioID = @conteggioid
	)
	DELETE FROM  [FloorActivity].[tbl_ConteggiModifications] WHERE ConteggioID = @conteggioid
	DELETE FROM Accounting.tbl_ConteggiValues WHERE ConteggioID = @conteggioid
	DELETE FROM Accounting.tbl_Conteggi WHERE ConteggioID = @conteggioid

	COMMIT TRANSACTION trn_DeleteConteggio
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteConteggio		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
RETURN @ret

GO
