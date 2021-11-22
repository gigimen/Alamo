SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [Techs].[usp_EnterRAMClear]
@InterventoID	INT,
@IpAddr			INT,
@VisoreUserID	INT,
@TISPrima		INT,
@TISDopo		INT,
@GMPrima		INT,
@GMDopo			INT,
@TOSPrima		INT,
@TOSDopo		INT,
@EseguitoRAMClear bit,
@EseguitoGiochiTest BIT,
@TimeStampLoc	datetime OUTPUT
AS

if not exists(select InterventoID from Techs.RapportiTecnici where InterventoID = @InterventoID)
begin
	raiserror('Invalid interventoID (%d) specified ',16,1,@InterventoID)
	return 1
end

if @IpAddr IS null 
begin
	raiserror('Invalid @IpAddr specified ',16,1)
	return 1
end

if not exists(select InterventoID from [Techs].[tbl_InterventiSlot_SlotsDRGT] where InterventoID = @InterventoID AND IpAddr = @IpAddr)
begin
	raiserror('Specified slot not associated to interventoID (%d)',16,1,@InterventoID)
	return 1
end

if not exists( select UserID from CasinoLayout.Users where UserID = @VisoreUserID)
begin
	raiserror('Invalid VisoreUserID (%d) specified',16,1,@VisoreUserID)
	return(1)
end



declare @RAMClearID int,
@body nvarchar(max),
@subj nvarchar(max),
@lastUser nvarchar(32)

select @lastUser = LastUser from Techs.vw_AllInterventiSlotDRGT where [InterventoID] = @interventoID
declare @slotNr varchar(32)
select @slotNr = [Techs].[fn_IPAddrToPosition](@IpAddr)


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterRAMClear

BEGIN TRY  



	set @timestampLoc = GETUTCDATE()

	if @RAMClearID is null
	--we have to create the new ram clear
	begin
		set @subj = 'Nuovo RAMClear slot ' + @slotNr
		INSERT INTO [Techs].[RAMClear]
			   ([VisoreUserID]
			   ,[TISPrima]
			   ,[TISDopo]
			   ,[GMPrima]
			   ,[GMDopo]
			   ,[TOSPrima]
			   ,[TOSDopo]
				,EseguitoRAMClear
				,EseguitoGiochiTest 
			   ,[InsertTimeStampUTC]
			   )
		 VALUES
			   (@VisoreUserID
			   ,@TISPrima
			   ,@TISDopo
			   ,@GMPrima
			   ,@GMDopo
			   ,@TOSPrima
			   ,@TOSDopo
				,@EseguitoRAMClear
				,@EseguitoGiochiTest 
			   ,@timestampLoc			
				)

		set @RAMClearID = SCOPE_IDENTITY()

		--mark the ram clear into Techs.InterventiSlot_Slots table
		update [Techs].[tbl_InterventiSlot_SlotsDRGT]
		set RAMClearID = @RAMClearID
		where [InterventoID] = @interventoID AND IpAddr=@IpAddr


	end
	else
	begin
		set @subj = 'Aggiornamento RAMClear slot ' + @slotNr
		--we have already a ram clear in the database
		--update it
		UPDATE [Techs].[RAMClear]
		SET   [VisoreUserID] = @VisoreUserID
			  ,[TISPrima] = @TISPrima
			  ,[TISDopo] = @TISDopo
			  ,[GMPrima] = @GMPrima
			  ,[GMDopo] = @GMDopo
			  ,[TOSPrima] = @TOSPrima
			  ,[TOSDopo] = @TOSDopo
				,EseguitoRAMClear = @EseguitoRAMClear
				,EseguitoGiochiTest = @EseguitoGiochiTest
			  ,[InsertTimeStampUTC] = @timestampLoc
		WHERE [RAMClearID] = @RAMClearID
	end



	set @timestampLoc = [GeneralPurpose].[fn_UTCToLocal](1,@timestampLoc)





	COMMIT TRANSACTION trn_EnterRAMClear

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterRAMClear
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	return @ret
END CATCH




set	@body = N'<HTML><BODY bgColor=''cyan''>
<CENTER><font color=#996666 size=28pt>' + @subj + '</font>
<br>											
<br>											
<br>RAM Clear											
<br>											
<br>Slot Nr: ' + @slotNr + '
<br>											
<br>Data e Ora: ' + convert(nvarchar(16),@timestampLoc,0) + '
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
		@bod = @body, --N'test del gruppo ramclear',
		@rec = /*N'l.menegolo@casinomendrisio.ch',--*/N'ramclear@casinomendrisio.ch',
		@from = 'tech@casinomendrisio.ch'

return @ret
GO
