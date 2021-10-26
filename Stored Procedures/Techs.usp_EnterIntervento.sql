SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_EnterIntervento] 
@Descr				varchar(4096)	,
@StatoTypeID		int				,
@RichiedenteID		int				,
@UAID				INT				,
@TimeLoc			DATETIME		,
@Tecnico2UserID		INT				,
@HistDescr			varchar(4096)	,
@RichiestaID		int				,
@perQuando			datetime		,
@interventoID		INT				OUTPUT	
AS

declare @interventoHistoryID int,
		@TimeUTC		datetime

if @TimeLoc is null 
begin
	raiserror('Invalid Time specified',16,1)
	return 1
end

if @StatoTypeID is null or not exists(select StatoTypeID from Techs.StatoTypes where StatoTypeID = @StatoTypeID)
begin
	raiserror('Invalid StatoTypeID specified',16,1,@StatoTypeID)
	return 1
end

if @RichiedenteID is null or not exists(select RichiedenteID from Techs.Richiedenti where RichiedenteID = @RichiedenteID)
begin
	raiserror('Invalid RichiedenteID specified',16,1,@RichiedenteID)
	return 1
end	

--if a richiesta is specified mak sure it is of the corret type
if @RichiestaID is not null 
and not exists
(
select RichiestaID from Techs.Richieste 
where RichiestaID = @RichiestaID 
--tipo richiesta is intervento tecnico o facility
and RichiestaTypeID IN (3,4)
--this must be null
AND MaterialeFacilityID is null 
AND MaterialeTecnicoID IS null
)
begin
	raiserror('Invalid RichiestaID (%d) specified',16,1,@RichiestaID)
	return 1
end

if @RichiestaID is not null and @interventoID is not NULL
and not exists
(
select RichiestaID from Techs.Richieste 
where RichiestaID = @RichiestaID 
--tipo richiesta is intervento tecnico o facility
and RichiestaTypeID IN (3,4)
AND InterventoID = @interventoID
)
BEGIN
	--make sure it refers to the original richiesta
	raiserror('RichiestaID (%d) is not the original one for Intervento(%d)',16,1,@RichiestaID,@interventoID)
	return 1
end


declare @userName varchar(32)
declare @userID int
select 
@userID = UserID,
@userName = UserName 
from FloorActivity.vw_AllUserAccesses
where UserAccessID = @UAID


if @userID is null
begin
	raiserror('Invalid user access specified',16,1)
	return (2)
end
if @interventoID is not null and (@HistDescr is null or LEN(@HistDescr) = 0)
begin
	raiserror('Invalid HistDescr specified',16,1)
	return (3)
end

IF @StatoTypeID = 4 --is sospeso 
AND @RichiestaID is not null 
AND (@perQuando IS NULL OR @PerQuando < DATEADD(dd, 0, DATEDIFF(dd, 0, getdate())))
begin
	raiserror('Must specify a valid Per quando date',16,1)
	return (3)
end
--it comes from humans convert it into utc
set @TimeUTC = GeneralPurpose.fn_UTCToLocal(0,@TimeLoc)

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterIntervento

BEGIN TRY  


if (@interventoID is null) --we ave to create the intervento first
begin
	
	if @RichiestaID is not null 
		select @HistDescr = 'Creazione nuovo intervento da richiesta di ' 
			+ Richiedente
			+ ': '
			+ Nota
		from Techs.vw_AllRichieste
		where RichiestaID = @RichiestaID and RichiestaTypeID IN(3,4)
	else
		set @HistDescr = 'Creazione nuovo intervento '

	INSERT INTO [Techs].[Interventi]
			   ([InterventoTimeStampUTC]
			   ,[OwnerUserID]
			   ,[Tecnico2UserID]
			   ,[Descrizione]
			   ,[StatoTypeID]
			   ,[RichiedenteID])
	VALUES
			   (@TimeUTC
			   ,@userID
			   ,@Tecnico2UserID
			   ,@Descr
			   ,@StatoTypeID
			   ,@RichiedenteID)
	
	--store new interventoID
	set @interventoID = @@IDENTITY
	
	
	--insert creation event in history
	INSERT INTO [Techs].[InterventiHistory]
			   ([InterventoID]
			   ,InsertTimeStampUTC
			   ,[InsertUserAccessID]
			   ,[HistDescr])
	VALUES
			   (@interventoID
			   ,getutcdate()
			   ,@UAID
			   ,@HistDescr)


end
else
begin
	
	--update information for current intervento
	UPDATE [Techs].[Interventi]
	   SET --[InterventoTimeStampUTC] = @TimeUTC --never change the timesamp
		  --,[OwnerUserID] = <OwnerUserID, int,> --never change the owner
		  [Tecnico2UserID]		= @Tecnico2UserID
		  ,[Descrizione]		= @Descr
		  ,[StatoTypeID]		= @StatoTypeID
		  ,[RichiedenteID]		= @RichiedenteID
	 WHERE InterventoID			= @interventoID

	--enter new entry in table [InterventiHistory]
	INSERT INTO [Techs].[InterventiHistory]
		   (
		   [InterventoID]
		   ,InsertTimeStampUTC
		   ,[InsertUserAccessID]
		   ,[HistDescr]
		   )
	VALUES
		   (@interventoID
		   ,@TimeUTC
		   ,@UAID
		   ,@HistDescr)


end


if @RichiestaID is not null 
begin

	IF @StatoTypeID = 4     --update perquando field 
		UPDATE	[Techs].[Richieste]
			SET	InterventoID = @interventoID,
			Nota = @Descr,
			PerQuando = @perQuando
		WHERE RichiestaID = @RichiestaID and RichiestaTypeID IN (3,4)
	else
		UPDATE	[Techs].[Richieste]
			SET	InterventoID = @interventoID,
			Nota = @Descr
	WHERE RichiestaID = @RichiestaID and RichiestaTypeID IN (3,4)

	--broadcast presa in carico 

	DECLARE @attribs varchar(4096)
	SELECT @attribs = 
		'RichiestaID=''' + CAST(RichiestaID as varchar(32)) + '''' +
		' InterventoID=''' + CAST(@interventoID as varchar(32)) + '''' +
		' RichiestaTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](OraRichiesta) + '''' +
--		' IncaricoTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](OraIncarico) + '''' +
		' Nota=''' + Nota + '''' +
		' Priorita=''' + Priorita + '''' +
		' TipoRichiestaID=''' + cast(RichiestaTypeID as varchar(16)) + '''' +
		' TipoRichiestaDescr=''' + [RichiestaTypeDescription] + '''' 
	FROM Techs.vw_AllRichieste 
	WHERE RichiestaID = @RichiestaID  
	EXECUTE GeneralPurpose.usp_BroadcastMessage 'PresaInCarico', @attribs

/*
	--manda anche una mail di presa in carico
	declare @body nvarchar(max),
	@to nvarchar(max)

	select @body = N'<HTML><BODY>
	<CENTER><font color=#669966 size=28pt>Presa in carico richiesta intervento</font>
	<br>											
	<br>											
	<br>Data e Ora: ' + convert(nvarchar(24),GETDATE(),13) + '
	<br>
	<br>											
	<br>											
	<table bgcolor=#e4e4e4 border=1>
		<font color=''blue'' size=18pt>	
		<tr><td width=200>Richiesta nr</td><td width=200>Richiesto da</td><td width=200>Presa in carico da</td><td width=200>Nota</td></tr>		  
		</font>
		<tr><td>'+cast(RichiestaID as varchar(32))+'</td><td>'+Richiedente+'</td><td>'+@userName+'</td><td>'+Nota+'</td></tr>
	</table>
	</CENTER></BODY></HTML>'
	from Techs.vw_AllRichieste 
	where RichiestaID = @RichiestaID and RichiestaTypeID = 2

	select @to = Email from Techs.Richiedenti where RichiedenteID = 1 --il capo dei tecnici
	--if richiedente has a email add to receipients list
	if exists (select RichiedenteID from Techs.Richiedenti where RichiedenteID = @RichiedenteID and Email is not null) 
		select @to += ';' + Email from Techs.Richiedenti where RichiedenteID = @RichiedenteID --il richiedente

	EXEC	[GeneralPurpose].[usp_EmailMessage]
			@sub = N'Presa in carico richiesta intervento',
			@bod = @body, --N'test del gruppo ramclear',
			@rec = @to,
			@from = 'tech01@cmendrisio.office.ch'
*/
end

	COMMIT TRANSACTION trn_EnterIntervento

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterIntervento
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
