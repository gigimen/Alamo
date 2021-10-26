SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Techs].[usp_DeleteStatoContatori] 
@InterventoID	INT,
@COD_MACHIN varchar(8), 
@DAT_DDEF DATETIME,
@FloorSfr	bit
AS

if not exists(select InterventoID from Techs.RapportiTecnici where InterventoID = @InterventoID)
begin
	raiserror('Invalid interventoID (%d) specified ',16,1,@InterventoID)
	return 1
end

if @COD_MACHIN IS null or LEN(@COD_MACHIN) = 0 
begin
	raiserror('Invalid @COD_MACHIN specified ',16,1)
	return 1
END

declare @ret int
set @ret = 0

/*
declare @StatoContatoriID int

SELECT @StatoContatoriID = StatoContatoriID
FROM Techs.InterventiSlot_Slots slo
inner join [Galaxis]..MIS.AD_ALL_SLOT_DEFINITIONS gal on slo.COD_MACHIN = gal.smdbid and gal.dat_ddef = slo.dat_ddef and cast(gal.FloorSfr as bit) = @FloorSfr
where slo.[InterventoID] = @InterventoID 
AND 	@COD_MACHIN = gal.smdbid and	@dat_ddef = gal.dat_ddef and cast(gal.FloorSfr as bit) = @FloorSfr


if @StatoContatoriID is null
begin
	raiserror('Invalid @COD_MACHIN %s, there is not a ram clear defined for this machine!!',16,1,@COD_MACHIN)
	return 1
end	




BEGIN TRANSACTION trn_DeleteStatoContatori

BEGIN TRY  

    
    
    
    --update the ram clear into Techs.InterventoSlot_Slots table
    update Techs.InterventiSlot_Slots
    set StatoContatoriID = null
    where COD_MACHIN = @COD_MACHIN and dat_ddef = @dat_ddef  and FloorSfr = @FloorSfr and InterventoID = @InterventoID	
    
    --delete it
    delete from [Techs].[StatoContatori]
    WHERE [StatoContatoriID] = @StatoContatoriID
    	
	COMMIT TRANSACTION trn_DeleteStatoContatori

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteStatoContatori
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
*/
return @ret
GO
