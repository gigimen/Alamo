SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Techs].[usp_DeleteRAMClear] 
@InterventoID	INT,
@IpAddr bit
AS

declare @slotNr varchar(32)
select @slotNr = [Techs].[fn_IPAddrToPosition](@IpAddr)

declare @RAMClearID int

SELECT @RAMClearID = RAMClearID
FROM [Techs].[tbl_InterventiSlot_SlotsDRGT]  slo
where [InterventoID] = @interventoID AND IpAddr=@IpAddr


if @RAMClearID is null
begin
	raiserror('Could not delete machine %s, the machine is not linked to this intervento!!',16,1,@slotNr)
	return 1
end	

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteRAMClear

BEGIN TRY  

	--update the ram clear into Techs.InterventoSlot_Slots table
	update [Techs].[tbl_InterventiSlot_SlotsDRGT] 
	set RAMClearID = null
	where [InterventoID] = @interventoID AND IpAddr=@IpAddr	


	--delete it
	IF NOT EXISTS (SELECT RAMClearID
		FROM [Techs].[tbl_InterventiSlot_SlotsDRGT]  slo
		where [InterventoID] = @interventoID AND RAMClearID=@RAMClearID)

		DELETE from [Techs].[RAMClear] WHERE [RAMClearID] = @RAMClearID
	


	COMMIT TRANSACTION trn_DeleteRAMClear

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteRAMClear
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
