SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Techs].[usp_EnterRichiesta] 
@RichiedenteID int, 
@Nota varchar(1024), 
@PrioritaID int, 
@RichiestaTypeID INT,
@PerQuando	DATETIME
AS

if @Nota is null or len(@Nota ) = 0
begin
	raiserror('Invalid Nota specified or Nota is empty!!',16,1)
	return 1
end

declare @rich nvarchar(32),@priorita varchar(32)
select @rich = NomeReparto from Techs.Richiedenti where RichiedenteID = @RichiedenteID and Richiedente = 1

if @rich is null
begin
	raiserror('Invalid RichiedenteID (%d) specified',16,1,@RichiedenteID)
	return (2)
end

select @priorita = PrioritDescr from Techs.Priorita where PrioritaID = @PrioritaID

if @priorita is null
begin
	raiserror('Invalid PrioritaID (%d) specified',16,1,@PrioritaID)
	return 3
END

DECLARE @TipoRichiestaDescr VARCHAR(50)
SELECT @TipoRichiestaDescr= RichiestaTypeDescription FROM Techs.RichiestaTypes WHERE RichiestaTypeID= @RichiestaTypeID
if @TipoRichiestaDescr IS null
begin
	raiserror('Invalid TipoRichiestaID (%d) specified',16,1,@RichiestaTypeID)
	return 4
END

declare @utcnow datetime
set @utcnow = GETUTCDATE()


IF @PerQuando IS NOT NULL AND @PerQuando < DATEADD(dd, 0, DATEDIFF(dd, 0, getdate()))
begin
	raiserror('PerQuando not valid: is in the past!!',16,1)
	return 5
END


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterRichiesta

BEGIN TRY  

	INSERT INTO Techs.Richieste
		(RichiedenteID, Nota, PrioritaID, RichiestaTypeID,InsertTimeStampUTC,PerQuando) 
		VALUES (@RichiedenteID, @Nota, @PrioritaID, @RichiestaTypeID,@utcnow,@PerQuando)


	SET @utcnow = GeneralPurpose.fn_UTCToLocal(1,@utcnow)

	IF @PerQuando IS NULL
		SET @PerQuando = 0

	--broadcast new richiesta
	declare @attribs varchar(4096)
	set @attribs = 
		'UserID=''' + CAST(@RichiedenteID as varchar(32)) + '''' +
		' UserName=''' + @rich + '''' +
		' RichiestaID=''' + + CAST(SCOPE_IDENTITY() as varchar(32)) + '''' +
		' RichiestaTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@utcnow) + '''' +
		' PerQuando=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@PerQuando) + '''' +
		' Nota=''' + @Nota + '''' +
		' Priorita=''' + @priorita + '''' +
		' TipoRichiestaID=''' + cast(@RichiestaTypeID as varchar(16)) + '''' +
		' TipoRichiestaDescr=''' + @TipoRichiestaDescr + '''' 
 
	execute [GeneralPurpose].[usp_BroadcastMessage] 'Richiesta',@attribs

/*/

--send an email to capo dei tecnici
declare @body nvarchar(max),
@subj nvarchar(max),
@to nvarchar(max),
@fromAddr nvarchar(max),
@tipo nvarchar(16)

if @TipoRichiesta = 1
	set @tipo = N'Intervento'
else
	set @tipo = N'Ordine'

set @subj = N'Nuova Richiesta ' + @tipo
set	@body = N'<HTML><BODY bgColor=''cyan''>
<CENTER><font color=#996666 size=28pt>' + @subj + '</font>
<br>											
<br>											
<br>Data e Ora: ' + convert(nvarchar(24),GETDATE(),13) + '
<br>											
<br>											
<table bgcolor=#e4e4e4 border=1>
	<font color=''blue'' size=18pt>	
	<tr><td width=200>Richiesta nr</td><td width=200>Richiesto da</td><td width=200>Nota</td><td width=200>Priorità</td></tr>		  
	</font>
	<tr><td>'+cast(SCOPE_IDENTITY() as varchar(32))+'</td><td>'+@rich+'</td><td>'+@Nota+'</td><td>'+@priorita+'</td></tr>
</table>
</CENTER></BODY></HTML>'

select @to = Email from Techs.Richiedenti where RichiedenteID = 1 --il capo dei tecnici
select @fromAddr = Email from Techs.Richiedenti where RichiedenteID = @RichiedenteID --il richiedente
if @fromAddr is null
	set @fromAddr = N'tech01@cmendrisio.office.ch'
	
EXEC	[GeneralPurpose].[usp_EmailMessage]
		@sub = @subj,
		@bod = @body,
		@rec = @to,
		@from = @fromAddr

		*/


	COMMIT TRANSACTION trn_EnterRichiesta

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterRichiesta
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
