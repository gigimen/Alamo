SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Snoopy].[usp_NewLRDDeletePepCheck] 
@PepCheckID int
AS



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDDeletePepCheck

BEGIN TRY  


	delete from Snoopy.tbl_PepChecks where PepCheckID = @PepCheckID


	--delete also in giotto database
	delete from Snoopy.tbl_PepChecks where PepCheckID = @PepCheckID


	COMMIT TRANSACTION trn_NewLRDDeletePepCheck

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDDeletePepCheck
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
