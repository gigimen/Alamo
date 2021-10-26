SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[usp_CreateTransaction]    Script Date: 07/19/2012 14:09:54 ******/
--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_EnterRapportoTecnico] 
@interventoID		INT,
@Problema			varchar(4096),
@Soluzione			varchar(4096)
AS

if not exists(select InterventoID from Techs.InterventiSlot where InterventoID = @interventoID)
begin
	raiserror('Invalid interventoID (%d) specified ',16,1,@interventoID)
	return 1
end

/*
if @Problema is null or len(@Problema) = 0 
begin
	raiserror('Invalid Problema specified ',16,1)
	return 1
end

if @Soluzione is null or len(@Soluzione) = 0 
begin
	raiserror('Invalid Soluzione specified ',16,1)
	return 1
end

*/
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterRapportoTecnico

BEGIN TRY  




	if not exists (select InterventoID from Techs.RapportiTecnici where InterventoID = @interventoID) 
	--we ave to create the rapporto tecnico
	begin
		--insert now the entry in table [Techs].[InterventiSlot]
	INSERT INTO [Techs].[RapportiTecnici]
			   ([InterventoID]
			   ,[Problema]
			   ,[Soluzione])
		 VALUES
			   (@InterventoID
			   ,@Problema
			   ,@Soluzione)           
	end
	else
	begin
		UPDATE [Techs].[RapportiTecnici]
		SET 
			[Problema] = @Problema,
			[Soluzione] = @Soluzione
		where [InterventoID] = @interventoID
	end


	COMMIT TRANSACTION trn_EnterRapportoTecnico

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterRapportoTecnico
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
