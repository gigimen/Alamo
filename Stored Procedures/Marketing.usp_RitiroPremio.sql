SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [Marketing].[usp_RitiroPremio]
@AssegnazionePremioID		int,
@SiteID						INT,
@oraRitiroLoc				DATETIME output
AS

--check input values
if @AssegnazionePremioID is null or not exists (select AssegnazionePremioID from Marketing.tbl_AssegnazionePremi where AssegnazionePremioID = @AssegnazionePremioID)
begin
	raiserror('Invalid AssegnazionePremioID (%d) specified',16,1,@AssegnazionePremioID)
	return (1)
end

if @SiteID is null or not exists (select SiteID from CasinoLayout.Sites where SiteID = @SiteID)
begin
	raiserror('Invalid SiteID (%d)',16,1,@SiteID)
	return (3)
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_RitiroPremio

BEGIN TRY  



	--marka che l'ordine è stato consumato
	SET @oraRitiroLoc = GETUTCDATE()
	update Marketing.tbl_AssegnazionePremi
	set RitiratoTimeStampUTC = @oraRitiroLoc,
		[RitiratoGamingDate] = GeneralPurpose.fn_GetGamingDate(@oraRitiroLoc,1,7),
		RitiroSiteID = @SiteID
	where AssegnazionePremioID = @AssegnazionePremioID

	--in caso di premio natale 2017 cerca l'alternativo e cancellalo
	if exists
	(
		select AssegnazionePremioID from Marketing.tbl_AssegnazionePremi
		where AssegnazionePremioID = @AssegnazionePremioID
		and OffertaPremioID in (98,99) --vignetta 2018 e bluetooth natale 2017
	)
	begin
		declare @CustomerID int,
		@OffertaPremioID int	

		select 	@CustomerID = CustomerID, @OffertaPremioID = OffertaPremioID from Marketing.tbl_AssegnazionePremi
		where AssegnazionePremioID = @AssegnazionePremioID


		declare @altAssegnazioneID int
		if @OffertaPremioID = 98
			select 	@altAssegnazioneID = AssegnazionePremioID from Marketing.tbl_AssegnazionePremi
				where OffertaPremioID = 99 and CustomerID = @CustomerID
		else
			select 	@altAssegnazioneID = AssegnazionePremioID from Marketing.tbl_AssegnazionePremi
				where OffertaPremioID = 98 and CustomerID = @CustomerID

		if @altAssegnazioneID is not null --cancellala
		begin
			update Marketing.tbl_AssegnazionePremi
			set [CancelTimeUTC] = @oraRitiroLoc
			where AssegnazionePremioID = @altAssegnazioneID
		end
	end


	SET @oraRitiroLoc = GeneralPurpose.fn_UTCToLocal(1,@oraRitiroLoc)


	COMMIT TRANSACTION trn_RitiroPremio

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RitiroPremio
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
