SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF


CREATE PROCEDURE [Techs].[usp_LinkInterventoSlot]
@interventoID	INT,
@IpAddr			INT,
@Add			BIT

AS

if not exists(select InterventoID from Techs.InterventiSlot where InterventoID = @interventoID)
begin
	raiserror('Invalid interventoID (%d) specified ',16,1,@interventoID)
	return 1
end



if @Add <> 1
begin
	--make sure we are not deleting a different slot slot
	IF not exists (SELECT InterventoID	FROM [Techs].[tbl_InterventiSlot_SlotsDRGT] slo
	where slo.[InterventoID] = @interventoID AND IpAddr=@IpAddr)
	begin
		declare @slotNr varchar(32)
		select @slotNr = [Techs].[fn_IPAddrToPosition](@IpAddr)
		raiserror('Could not delete machine %s, the machine is not linked to this intervento!!',16,1,@slotNr)
		return 1
	end	
end


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_LinkInterventoSlot

BEGIN TRY  





	if @Add = 1
	begin 	

		INSERT INTO [Techs].[tbl_InterventiSlot_SlotsDRGT]
           ([InterventoID]
           ,[IpAddr])

		VALUES
				   (@InterventoID
				   ,@IpAddr
				   )
	end
	else
	begin

		--print 'deleting ' + @COD_MACHIN
		--print @dat_ddef

		--delete associated ramclear and cambio meccanici if any
		declare @ramclearID INT,@StatoContatoriID INT
		select 
			@ramclearID			= RAMClearID,
			@StatoContatoriID	= StatoContatoriID 
		FROM [Techs].[tbl_InterventiSlot_SlotsDRGT]
		WHERE [InterventoID] = @interventoID AND IpAddr=@IpAddr
	
        
		if @ramclearID is not null and not exists (select * FROM [Techs].[tbl_InterventiSlot_SlotsDRGT]	WHERE [InterventoID] = @interventoID AND IpAddr<>@IpAddr)
		begin
			delete from [Techs].[RAMClear] where RAMClearID= @ramclearID
		end	
	
		if @StatoContatoriID is not null and not exists (select * FROM [Techs].[tbl_InterventiSlot_SlotsDRGT]	WHERE [InterventoID] = @interventoID AND IpAddr<>@IpAddr)
		begin
			delete from [Techs].[StatoContatori] where StatoContatoriID= @StatoContatoriID
		end	
	
		--unlink the slot from the intevento
		delete from [Techs].[tbl_InterventiSlot_SlotsDRGT]
		WHERE [InterventoID] = @interventoID AND IpAddr=@IpAddr

	end

	COMMIT TRANSACTION trn_LinkInterventoSlot

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_LinkInterventoSlot
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
