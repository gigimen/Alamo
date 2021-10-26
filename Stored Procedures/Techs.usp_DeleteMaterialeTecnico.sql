SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_DeleteMaterialeTecnico] 
@MaterialeTecnicoID		INT
AS


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteMaterialeTecnico

BEGIN TRY  



	--we can now delete the history
	delete from Techs.MaterialeTecnicoHistory
	where [MaterialeTecnicoID] = @MaterialeTecnicoID


	--delete all articoli linked to this ordine materiale tecnico
	DELETE FROM Techs.MaterialeTecnico_Articoli
		  WHERE [MaterialeTecnicoID] = @MaterialeTecnicoID

	--finally delete ordine
	DELETE FROM Techs.MaterialeTecnico WHERE MaterialeTecnicoID = @MaterialeTecnicoID


	COMMIT TRANSACTION trn_DeleteMaterialeTecnico

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteMaterialeTecnico
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
