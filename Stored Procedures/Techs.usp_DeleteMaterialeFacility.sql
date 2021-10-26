SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_DeleteMaterialeFacility] 
@FacilityID		INT
AS

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteMaterialeFacility

BEGIN TRY  

	--we can now delete the history
	delete from Techs.MaterialeFacilityHistory
	where MaterialeFacilityID = @FacilityID

	--maybe there is a richiesta linked to this facility
	declare @RichiestaID int
	select @RichiestaID = RichiestaID from [Techs].[Richieste] WHERE MaterialeFacilityID = @FacilityID and RichiestaTypeID = 1 and InterventoID is null
	if @RichiestaID is not null
	begin
		execute [Techs].[usp_DeleteRichiesta] @richiestaID
	end

	--delete articoli possibly linked to this Facility
	DELETE FROM Techs.MaterialeFacility_Articoli WHERE MaterialeFacilityID = @FacilityID

	--finally delete ordine
	DELETE FROM Techs.MaterialeFacility WHERE MaterialeFacilityID = @FacilityID

	COMMIT TRANSACTION trn_DeleteMaterialeFacility

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteMaterialeFacility
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
