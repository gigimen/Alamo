SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Techs].[usp_EnterInterventoServizioFacility] 
@Descr				varchar(4096)	,
@Provvedimento		varchar(4096)	,
@StatoTypeID		int				,
@RichiedenteID		int				,
@UAID				INT				,
@DittaID			INT				,
@ServiziTypeID		INT				,
@AllarmeTypeID		INT				,
@TimeLoc			DATETIME		,
@Tecnico2UserID		INT				,
@HistDescr			varchar(1024)	,
@RichiestaID		int				,
@perQuando			datetime		,
@interventoID		INT		OUTPUT
AS

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterInterventoFacility

BEGIN TRY  




	--first enter interventi servizi
	execute [Techs].[usp_EnterInterventoServizioTecnico]
	@Descr				,
	@StatoTypeID		,
	@RichiedenteID		,
	@UAID				,
	@DittaID			,
	@ServiziTypeID		,
	@AllarmeTypeID		,
	@TimeLoc			,
	@Tecnico2UserID		,
	@HistDescr			,
	@RichiestaID		,
	@perQuando			,
	@interventoID		OUTPUT



	if not exists (select InterventoID from [Techs].[InterventiServiziFacility] where InterventoID = @interventoID) 
	--we ave to create the intervento slot first
	begin

		--insert now the entry in table [Techs].[[InterventiServiziFacility]]
		INSERT INTO [Techs].[InterventiServiziFacility]
			   ([InterventoID]
			   ,[Provvedimento])
		 VALUES
			   (@InterventoID,
			   @Provvedimento)

	end
	else
	begin
		update [Techs].[InterventiServiziFacility]
		set [Provvedimento]		= @Provvedimento
		where [InterventoID] = @interventoID

	end



	COMMIT TRANSACTION trn_EnterInterventoFacility

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterInterventoFacility
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret

GO
