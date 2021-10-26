SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Techs].[usp_EnterMaterialeTecnico] 
@Descr				VARCHAR(4096)	,
@StatoOrdineID		INT				,
@RichiedenteID		INT				,
@UAID				INT				,
@TimeLoc			DATETIME		OUTPUT,
@HistDescr			VARCHAR(1024)	,
@RichiestaID		INT				,
@perQuando			DATETIME		,
@MaterialeTecnicoID		INT				OUTPUT
AS



--if a richiesta is specified mak sure it is of the corret type
IF @RichiestaID IS NOT NULL 
AND NOT EXISTS
(
SELECT RichiestaID FROM Techs.Richieste 
WHERE RichiestaID = @RichiestaID 
--tipo richiesta is materiale tecnico
AND RichiestaTypeID = 2
--this must be null
AND InterventoID IS NULL 
AND MaterialeFacilityID IS NULL
)
BEGIN
	RAISERROR('Invalid RichiestaID specified',16,1,@RichiestaID)
	RETURN 1
END

IF @RichiestaID IS NOT NULL AND @MaterialeTecnicoID IS NOT NULL
AND NOT EXISTS
(
SELECT RichiestaID FROM Techs.Richieste 
WHERE RichiestaID = @RichiestaID 
--tipo richiesta is materiali tecnico
AND RichiestaTypeID = 2 
AND MaterialeTecnicoID = @MaterialeTecnicoID
)
BEGIN
	--make sure it refers to the original richiesta
	RAISERROR('RichiestaID (%d) is not the original one for MaterialeTecnicoID(%d)',16,1,@RichiestaID,@MaterialeTecnicoID)
	RETURN 1
END




IF @StatoOrdineID IS NULL OR NOT EXISTS(SELECT StatoOrdineID FROM Techs.StatiOrdine WHERE StatoOrdineID = @StatoOrdineID)
BEGIN
	RAISERROR('Invalid StatoOrdineID specified',16,1,@StatoOrdineID)
	RETURN 1
END

IF @RichiedenteID IS NULL OR NOT EXISTS(SELECT RichiedenteID FROM Techs.Richiedenti WHERE RichiedenteID = @RichiedenteID)
BEGIN
	RAISERROR('Invalid RichiedenteID specified',16,1,@RichiedenteID)
	RETURN 1
END	


DECLARE @userName VARCHAR(32),
		@userID INT,
		@TimeUTC		DATETIME
SELECT 
@userID = UserID,
@userName = UserName 
FROM FloorActivity.vw_AllUserAccesses
WHERE UserAccessID = @UAID

IF @userID IS NULL
BEGIN
	RAISERROR('Invalid user access specified',16,1)
	RETURN (2)
END

IF @MaterialeTecnicoID IS NOT NULL AND (@HistDescr IS NULL OR LEN(@HistDescr) = 0)
BEGIN
	RAISERROR('Invalid HistDescr specified',16,1)
	RETURN (3)
END

IF @StatoOrdineID = 4 --is sospeso 
AND @RichiestaID IS NOT NULL 
AND (@perQuando IS NULL OR @PerQuando < DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())))
BEGIN
	RAISERROR('Must specify a valid Per quando date',16,1)
	RETURN (3)
END

--it comes from humans convert it into utc
SET @TimeUTC = GETUTCDATE()
SET @TimeLoc = GeneralPurpose.fn_UTCToLocal(1,@TimeUTC)

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterMaterialeTecnico

BEGIN TRY  


	IF (@MaterialeTecnicoID IS NULL) --we have to create the intervento first
	BEGIN
	
		IF @RichiestaID IS NOT NULL 
			SELECT @HistDescr = 'Creazione nuovo ordine materiale tecnico da richiesta (' + CAST(@RichiestaID AS VARCHAR(16)) + ') di ' 
				+ Richiedente
				+ ': '
				+ Nota
			from Techs.vw_AllRichieste
			where RichiestaID = @RichiestaID and RichiestaTypeID = 2
		else
			set @HistDescr = 'Creazione nuovo ordine materiale tecnico '

	
		INSERT INTO Techs.MaterialeTecnico
			   ([InsertTimeStampUTC]
			   ,[OwnerUserID]
			   ,[Descrizione]
			   ,[StatoOrdineID]
			   ,[RichiedenteID])
  		VALUES
				   (@TimeUTC
				   ,@userID
				   ,@Descr
				   ,@StatoOrdineID
				   ,@RichiedenteID)
	
		--store new interventoID
		set @MaterialeTecnicoID = SCOPE_IDENTITY()
	
	
		--insert creation event in history
		INSERT INTO Techs.MaterialeTecnicoHistory
			   ([MaterialeTecnicoID]
			   ,[InsertUserAccessID]
			   ,[HistDescr])
 		VALUES
				   (@MaterialeTecnicoID
				   ,@UAID
				   ,@HistDescr)


	end
	else
	begin
	
		--update information for current intervento
		UPDATE Techs.MaterialeTecnico
		   SET  --[MaterialeTecnicoTimeStampUTC] = @TimeUTC never change the time
			  --,[OwnerUserID] = <OwnerUserID, int,> --never change the owner
			  [Descrizione]		= @Descr
			  ,[StatoOrdineID]	= @StatoOrdineID
			  ,[RichiedenteID]	= @RichiedenteID
		 WHERE MaterialeTecnicoID	= @MaterialeTecnicoID

		--enter new entry in table Techs.MaterialeTecnicoHistory
		INSERT INTO Techs.MaterialeTecnicoHistory
			   ([MaterialeTecnicoID]
			   ,[InsertUserAccessID]
			   ,[HistDescr])
 		VALUES
				   (@MaterialeTecnicoID
				   ,@UAID
				   ,@HistDescr)

	
	end


	if @RichiestaID is not null 
	begin
  
		IF @StatoOrdineID = 4     --in sospeso update perquando field 
			UPDATE	[Techs].[Richieste]
				SET	MaterialeTecnicoID = @MaterialeTecnicoID,
				Nota = @Descr,
				PerQuando = @perQuando
			WHERE RichiestaID = @RichiestaID and RichiestaTypeID = 2
		else
			UPDATE	[Techs].[Richieste]
				SET	MaterialeTecnicoID = @MaterialeTecnicoID,
					Nota = @Descr
		WHERE RichiestaID = @RichiestaID and RichiestaTypeID = 2

		--broadcast presa in carico richiesta
	
		DECLARE @attribs varchar(4096)
		SELECT @attribs = 
			'RichiestaID=''' + CAST(@RichiestaID as varchar(32)) + '''' +
			' MaterialeID=''' + CAST(@MaterialeTecnicoID as varchar(32)) + '''' +
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
		<CENTER><font color=#669966 size=28pt>Presa in carico richiesta ordine materiale tecnico</font>
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
		where RichiestaID = @RichiestaID and RichiestaTypeID = 3

		select @to = Email from Techs.Richiedenti where RichiedenteID = 1 --il capo dei tecnici
		--if richiedente has a email add to receipients list
		if exists (select RichiedenteID from Techs.Richiedenti where RichiedenteID = @RichiedenteID and Email is not null) 
			select @to += ';' + Email from Techs.Richiedenti where RichiedenteID = @RichiedenteID --il richiedente

		EXEC	[GeneralPurpose].[usp_EmailMessage]
				@sub = N'Presa in carico richiesta ordine materiale tecnico',
				@bod = @body, --N'test del gruppo ramclear',
				@rec = @to,
				@from = 'tech01@cmendrisio.office.ch'
	*/
	END
    
	COMMIT TRANSACTION trn_EnterMaterialeTecnico

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterMaterialeTecnico
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
