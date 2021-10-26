SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Techs].[usp_EnterStatoContatori] 
@InterventoID	INT,
@IpAddr			INT,
@VisoreUserID	INT,
@TIS		INT,
@GM			INT,
@TOS		INT,
@TimeStampLoc	datetime output
AS

if not exists(select InterventoID from Techs.RapportiTecnici where InterventoID = @InterventoID)
begin
	raiserror('Invalid interventoID (%d) specified ',16,1,@InterventoID)
	return 1
end

if not exists(select InterventoID from Techs.InterventiSlot_Slots where InterventoID = @InterventoID)
begin
	raiserror('No slot associated to interventoID (%d)',16,1,@InterventoID)
	return 1
end

if not exists( select UserID from CasinoLayout.Users where UserID = @VisoreUserID)
begin
	raiserror('Invalid VisoreUserID (%d) specified',16,1,@VisoreUserID)
	return(1)
end

declare @SlotNr varchar(32)
select @SlotNr = [Techs].[fn_IPAddrToPosition](@IpAddr)


IF not exists (SELECT InterventoID	FROM [Techs].[tbl_InterventiSlot_SlotsDRGT] 
where [InterventoID] = @InterventoID AND IpAddr=@IpAddr)
begin
	raiserror('Could not delete machine %s, the machine is not linked to this intervento!!',16,1,@SlotNr)
	return 1
end	



declare @StatoContatoriID int,
@LocationNr INT,
@body nvarchar(max),
@subj nvarchar(max),
@lastUser nvarchar(32)

select @lastUser = LastUser from Techs.vw_AllInterventiSlotDRGT where [InterventoID] = @InterventoID


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterStatoContatori

BEGIN TRY  




	set @TimeStampLoc = GETUTCDATE()

	if @StatoContatoriID is null
	--we have to create the new ram clear
	begin
		set @subj = 'Nuovo StatoContatori slot ' + cast(@LocationNr as nvarchar(32))
		INSERT INTO [Techs].[StatoContatori]
			   ([VisoreUserID]
			   ,[TIS]
			   ,[GM]
			   ,[TOS]
				,[InsertTimeStampUTC]
			   )
		 VALUES
			   (@VisoreUserID
			   ,@TIS
			   ,@GM
			   ,@TOS
			   ,@TimeStampLoc			
				)

		set @StatoContatoriID = SCOPE_IDENTITY()


		--mark the StatoContatoriID into [Techs].[tbl_InterventiSlot_SlotsDRGT] table
		update [Techs].[tbl_InterventiSlot_SlotsDRGT]
		set StatoContatoriID = @StatoContatoriID
		where [InterventoID] = @InterventoID AND IpAddr=@IpAddr

	end
	else
	begin
		set @subj = 'Aggiornamento StatoContatori slot ' + cast(@LocationNr as nvarchar(32))
		--we have already a ram clear in the database
		--update it
		UPDATE [Techs].[StatoContatori]
		SET   [VisoreUserID] = @VisoreUserID
			  ,[TIS] = @TIS
			  ,[GM] = @GM
			  ,[TOS] = @TOS
			  ,[InsertTimeStampUTC] = @TimeStampLoc
		WHERE [StatoContatoriID] = @StatoContatoriID
	end



	set @TimeStampLoc = [GeneralPurpose].[fn_UTCToLocal](1,@TimeStampLoc)

	/*

	set	@body = N'<HTML><BODY bgColor=''cyan''>
	<CENTER><font color=#996666 size=28pt>' + @subj + '</font>
	<br>											
	<br>											
	<br>RAM Clear											
	<br>											
	<br>SMDBID: ' + @COD_MACHIN + '
	<br>											
	<br>Data e Ora: ' + convert(nvarchar(16),@TimeStampLoc,0) + '
	<br>											
	<br>Tecnico: ' + @lastUser + '
	<br>											
	<br>											
	<table bgcolor=#e4e4e4 border=1>
	<font color=''blue'' size=18pt>	
		<tr>
			<td width=360><left>Slot Meter</left></td>
			<td width=360><right>Prima</right></td>
			<td width=360><right>Dopo</rigth></td>
		</tr>		  
		<tr>		  
			<td><left> TI Meccanico</left></td>
			<td><right>' + cast(@TIMPrima as nvarchar(32)) + '</right></td>
			<td><right>' + cast(@TIMDopo  as nvarchar(32)) + '</rigth></td>
		</tr>
		<tr>	
			<td><left> TO Meccanico</left></td>
			<td><right>' + cast(@TOMPrima as nvarchar(32)) + '</right></td>
			<td><right>' + cast(@TOMDopo  as nvarchar(32)) + '</rigth></td>
		</tr>
		<tr>	
			<td><left> TI Elettornico</left></td>
			<td><right>' + cast(@TISPrima as nvarchar(32)) + '</right></td>
			<td><right>' + cast(@TISDopo  as nvarchar(32)) + '</rigth></td>
		</tr>
		<tr>	
			<td><left> TO Elettornico</left></td>
			<td><right>' + cast(@TOSPrima as nvarchar(32)) + '</right></td>
			<td><right>' + cast(@TOSDopo  as nvarchar(32)) + '</rigth></td>
		</tr>
		<tr>		  
			<td><left> Games</left></td>
			<td><right>' + cast(@GMPrima as nvarchar(32)) + '</right></td>
			<td><right>' + cast(@GMDopo  as nvarchar(32)) + '</rigth></td>
		</tr>
	</font>
	</table>
	</CENTER></BODY></HTML>'


	EXEC	[GeneralPurpose].[usp_EmailMessage]
			@sub = @subj,
			@bod = @body, --N'test del gruppo StatoContatori',
			@rec = N'StatoContatori@cmendrisio.office.ch',
			@from = 'tech@casinomendrisio.ch'
	*/



	COMMIT TRANSACTION trn_EnterStatoContatori

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterStatoContatori
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
