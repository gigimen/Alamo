SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_DeleteRichiesta] 
@richiestaID INT
AS

if @RichiestaID is not null and not exists(select RichiestaID from Techs.Richieste where RichiestaID = @richiestaID)
begin
	raiserror('Invalid RichistaID %d specified',16,1,@RichiestaID)
	return (4)
end

declare @body nvarchar(max),
@to nvarchar(max),
@RichiestaTypeID int


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteRichiesta

BEGIN TRY  




	--manda anche una mail di cancellazione richiesta
	select @to = Email from Techs.Richiedenti where RichiedenteID = 1 --il capo dei tecnici
	--if richiedente has an email add to receipients list
	if exists (
		select RichiestaID
		from Techs.Richieste r
		inner join  Techs.Richiedenti ri on ri.RichiedenteID = r.RichiedenteID
		where r.RichiestaID = @RichiestaID 
		and ri.Email is not null
		) 
		select @to += ';' + ri.Email 
		from Techs.Richieste r
		inner join  Techs.Richiedenti ri on ri.RichiedenteID = r.RichiedenteID
		where r.RichiestaID = @RichiestaID 
	
	select @body = N'<HTML><BODY>
	<CENTER><font color=''red'' size=28pt>Cancellazione Richiesta</font>
	<br>											
	<br>											
	<br>Data e Ora: ' + convert(nvarchar(24),GETDATE(),13) + '
	<br>
	<br>											
	<br>											
	<table bgcolor=#e4e4e4 border=1>
		<font color=''blue'' size=18pt>	
		<tr><td width=200>Richiesta nr</td><td width=200>Richiesto da</td><td width=200>Nota</td></tr>		  
		</font>
		<tr><td>'+cast(RichiestaID as varchar(32))+'</td><td>'+Richiedente+'</td><td>'+Nota+'</td></tr>
	</table>
	</CENTER></BODY></HTML>',
	@RichiestaTypeID = RichiestaTypeID
	from Techs.vw_AllRichieste 
	where RichiestaID = @RichiestaID


	--we can now delete the richiesta
	delete from Techs.Richieste
	where [RichiestaID] = @richiestaID


		DECLARE @attribs varchar(4096)
		Set @attribs = 'RichiestaID=''' + CAST(@RichiestaID as varchar(32)) + '''' +
			' TipoRichiestaID=''' + cast(@RichiestaTypeID as varchar(16)) + ''''

		EXECUTE GeneralPurpose.usp_BroadcastMessage 'CancRichiesta', @attribs

	--and finally send the notification	
	EXEC	[GeneralPurpose].[usp_EmailMessage]
			@sub = N'Cancellazione richiesta ',
			@bod = @body, --N'test del gruppo ramclear',
			@rec = @to,
			@from = 'tech01@cmendrisio.office.ch'

	COMMIT TRANSACTION trn_DeleteRichiesta

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteRichiesta
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
