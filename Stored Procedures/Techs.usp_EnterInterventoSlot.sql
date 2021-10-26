SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[usp_CreateTransaction]    Script Date: 07/19/2012 14:09:54 ******/
--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_EnterInterventoSlot] 
@Descr				varchar(4096)	,
@StatoTypeID		int				,
@RichiedenteID		int				,
@UAID				INT				,
@ProblemaSlotSubTypeID	INT				,
@SoluzioneSlotTypeID INT			,
@TimeLoc			DATETIME		,
@Tecnico2UserID		INT				,
@HistDescr			varchar(1024)	,
@interventoID		INT		OUTPUT
AS

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterInterventoSlot

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
	NULL				, --no richiesta for slots
	NULL				, --no perquando date
	@interventoID		OUTPUT




	if not exists (select InterventoID from [Techs].[InterventiSlot] where InterventoID = @interventoID) 
	--we ave to create the intervento slot first
	begin
		--insert now the entry in table [Techs].[InterventiSlot]
		INSERT INTO [Techs].[InterventiSlot]
			   (
			   [InterventoID]
			   ,[ProblemaSlotSubTypeID]
			   ,[SoluzioneSlotTypeID]
			   )
		 VALUES
			   (
			   @interventoID
			   ,@ProblemaSlotSubTypeID
			   ,@SoluzioneSlotTypeID
			   )
           
	end
	else
	BEGIN

		update
		[Techs].[InterventiSlot]
		set [ProblemaSlotSubTypeID] = @ProblemaSlotSubTypeID
			   ,[SoluzioneSlotTypeID] = @SoluzioneSlotTypeID
		where [InterventoID] = @interventoID

	
	end


	COMMIT TRANSACTION trn_EnterInterventoSlot

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterInterventoSlot
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret

GO
