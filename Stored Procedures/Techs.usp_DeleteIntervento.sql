SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_DeleteIntervento] 
@InterventoID		INT,
@UserAccessID		INT
AS



declare @TempRAMClearID TABLE  (RAMClearID INT )

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteIntervento

BEGIN TRY  



	--we can now delete the history
	delete from [Techs].[InterventiHistory]
	where [InterventoID] = @InterventoID


	--delete ramclear
	--store ramclearid into a temporary table

	INSERT  @TempRAMClearID
	select RAMClearID
	FROM [Techs].[InterventiSlot_Slots]
	WHERE InterventoID = @InterventoID

	--unlink from ramclear
	update [Techs].[InterventiSlot_Slots]
	set RAMClearID = null
	WHERE InterventoID = @InterventoID

	DELETE FROM [Techs].[RAMClear]
	WHERE RAMClearID in (select RAMClearID FROM @TempRAMClearID)


	--delete slots
	DELETE FROM [Techs].[InterventiSlot_Slots]
		  WHERE InterventoID = @InterventoID

	--delete rimborso
	IF EXISTS (SELECT InterventoID FROM [Techs].[Rimborsi] WHERE InterventoID = @InterventoID)
	BEGIN
	    --find shortpay in Accounting system
		DECLARE @slottransid INT
		SELECT 	@slottransid = SlotTransactionID FROM Accounting.tbl_SlotTransactions WHERE InterventoID = @InterventoID
		IF @slottransid IS NOT NULL
        begin
				EXECUTE [Accounting].[usp_DeleteSlotTransaction]
					@slottransID ,
					@UserAccessID 
		end
		DELETE FROM [Techs].[Rimborsi]  WHERE InterventoID = @InterventoID
	END
	--delete rapporto tecnico
	DELETE FROM [Techs].[RapportiTecnici]
		  WHERE InterventoID = @InterventoID

	--finally delete intervento
	DELETE FROM [Techs].InterventiSlot WHERE InterventoID = @InterventoID

	--maybe there is a richiesta linked to this intervento
	declare @RichiestaID int
	select @RichiestaID = RichiestaID from [Techs].[Richieste] WHERE InterventoID = @InterventoID and RichiestaTypeID = 2 and MaterialeFacilityID is null
	if @RichiestaID is not null
	begin
		execute [Techs].[usp_DeleteRichiesta] @richiestaID
	end

	DELETE FROM [Techs].InterventiServizi WHERE InterventoID = @InterventoID
	DELETE FROM [Techs].InterventiLiveGame WHERE InterventoID = @InterventoID
	DELETE FROM [Techs].Interventi WHERE InterventoID = @InterventoID

	COMMIT TRANSACTION trn_DeleteIntervento

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteIntervento
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH


return @ret
GO
