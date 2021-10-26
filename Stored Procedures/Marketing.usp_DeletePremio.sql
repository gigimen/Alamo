SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [Marketing].[usp_DeletePremio]
@AssegnazionePremioID		int
AS

--check input values
if @AssegnazionePremioID is null or not exists (select AssegnazionePremioID from Marketing.tbl_AssegnazionePremi where AssegnazionePremioID = @AssegnazionePremioID)
begin
	raiserror('Invalid AssegnazionePremioID (%d) specified',16,1,@AssegnazionePremioID)
	return (1)
end


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeletePremio

BEGIN TRY  




	DELETE from Marketing.tbl_AssegnazionePremi
	where AssegnazionePremioID = @AssegnazionePremioID


	--everything went fine commit it

	COMMIT TRANSACTION trn_DeletePremio

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeletePremio
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
