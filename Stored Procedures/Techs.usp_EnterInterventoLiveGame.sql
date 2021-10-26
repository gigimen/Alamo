SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Techs].[usp_EnterInterventoLiveGame] 
@Descr				varchar(4096)	,
@StatoTypeID		int				,
@RichiedenteID		int				,
@UAID				INT				,
@ProblemaLiveGameSubTypeID	INT		,
@SoluzioneLiveGameTypeID INT		,
@MachineLiveGameID	INT				,
@TableLiveGameID	INT				,
@ContaOre			INT				,
@TimeLoc			DATETIME		,
@Tecnico2UserID		INT				,
@HistDescr			varchar(1024)	,
@interventoID		INT		OUTPUT
AS

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterInterventoLiveGame

BEGIN TRY  



	--first enter a new intervento
	execute [Techs].[usp_EnterIntervento] 
	@Descr				,
	@StatoTypeID		,
	@RichiedenteID		,
	@UAID				,
	@TimeLoc			,
	@Tecnico2UserID		,
	@HistDescr			,
	NULL				, --no richiesta for live game
	NULL				, --no perquando date
	@interventoID		OUTPUT





	if not exists (select interventoID from [Techs].[InterventiLiveGame] where InterventoID = @interventoID) 
	--we ave to create the intervento slot first
	begin
		--insert now the entry in table [Techs].[InterventiLiveGame]
		INSERT INTO [Techs].[InterventiLiveGame]
			   (
			   [InterventoID]
			   ,[ProblemaLiveGameSubTypeID]
			   ,[SoluzioneLiveGameTypeID]
 				,MachineLiveGameID	
				,TableLiveGameID
				,ContaOre
			  )
		 VALUES
			   (
			   @interventoID
			   ,@ProblemaLiveGameSubTypeID
			   ,@SoluzioneLiveGameTypeID
				,@MachineLiveGameID	
				,@TableLiveGameID
				,@ContaOre
			 )
	end
	else
	begin
		update [Techs].[InterventiLiveGame]
		set [ProblemaLiveGameSubTypeID] = @ProblemaLiveGameSubTypeID
			   ,[SoluzioneLiveGameTypeID] = @SoluzioneLiveGameTypeID
   				,MachineLiveGameID=@MachineLiveGameID	
				,TableLiveGameID=@TableLiveGameID
				,ContaOre=@ContaOre
		where [InterventoID] = @interventoID
	end


	COMMIT TRANSACTION trn_EnterInterventoLiveGame

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterInterventoLiveGame
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
