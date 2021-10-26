SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




/****** Object:  StoredProcedure [dbo].[usp_CreateTransaction]    Script Date: 07/19/2012 14:09:54 ******/
--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_EnterInterventoServizioTecnico] 
@Descr				varchar(4096)	,
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

BEGIN TRANSACTION trn_EnterInterventoServizi

BEGIN TRY  


	--first update table interventi
	execute [Techs].[usp_EnterIntervento] 
	@Descr				,
	@StatoTypeID		,
	@RichiedenteID		,
	@UAID				,
	@TimeLoc			,
	@Tecnico2UserID		,
	@HistDescr			,
	@RichiestaID		,
	@perQuando			,
	@interventoID		OUTPUT



	if not exists (select InterventoID from [Techs].[InterventiServizi] where InterventoID = @interventoID) 
	--we ave to create the intervento slot first
	begin

		--insert now the entry in table [Techs].[InterventiServizi]
		INSERT INTO [Techs].[InterventiServizi]
				   ([InterventoID]
				   ,[ServiziTypeID]
				   ,[AllarmeTypeID]
				   ,[DittaID])
			VALUES
			   (
				@interventoID
			   ,@ServiziTypeID
			   ,@AllarmeTypeID
			   ,@DittaID
			 )

	end
	else
	begin
		update [Techs].[InterventiServizi]
		set 
				   [ServiziTypeID] = @ServiziTypeID
				   ,[AllarmeTypeID]	= @AllarmeTypeID
				   ,[DittaID]		= @DittaID
		where [InterventoID] = @interventoID

	end


	COMMIT TRANSACTION trn_EnterInterventoServizi

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterInterventoServizi
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
