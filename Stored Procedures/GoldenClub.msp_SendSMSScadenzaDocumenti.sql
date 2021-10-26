SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       PROCEDURE [GoldenClub].[msp_SendSMSScadenzaDocumenti]
AS

declare @TimeStampLoc datetime


set @TimeStampLoc = getdate()

declare @ret int
set @ret = CURSOR_STATUS ('global','reg_cursor')
--print 'CURSOR_STATUS returned ' + cast(@ret as varchar)
if @ret > -3
begin
	--print 'deallocting reg_cursor'
	DEALLOCATE reg_cursor
end
DECLARE reg_cursor CURSOR
   FOR
SELECT
	gc.CustomerID, 
	[GeneralPurpose].[fn_ProperCase](gc.LastName,DEFAULT,DEFAULT) as LName, 
	gc.Sesso,
	gc.GCExpirationDate,
	gc.SMSNumber,
	gc.MemberTypeID
FROM GoldenClub.vw_AllGoldenAndDragonMembers gc
WHERE     datepart(yy,gc.GCExpirationDate) = datepart(yy,GetDate() + 7) 
and datepart(mm,gc.GCExpirationDate) = datepart(mm,GetDate() + 7)                
and datepart(dy,gc.GCExpirationDate) = datepart(dy,GetDate() + 7)                
AND gc.GCCancelID is NULL
AND gc.GoldenClubCardID IS NOT null 
AND gc.smsnumber is not null
AND gc.SMSNumberDisabled = 0 --the customer did not disable sms
AND gc.SMSNumberChecked = 1 --sms has been successfully verified


OPEN reg_cursor
declare @buffer varchar(8000)
set @buffer =  ''
declare @message varchar(512)
declare @LastName  Varchar(256)
declare @Sesso	bit
declare @MemberTypeID	int
declare @SMSNumber Varchar(256)
declare @msg  Varchar(max)
declare @recp varchar(256)
declare @expDate datetime
declare @CustomerID int
declare @c int
declare @r INT
declare @allOK INT
set @c = 0
set @r = 0
SET @allOK = 1

FETCH NEXT FROM reg_cursor INTO @CustomerID,@LastName, @Sesso,@expDate,@SMSNumber,@MemberTypeID
WHILE (@@FETCH_STATUS <> -1 and @r = 0)
BEGIN
	set @message =  GoldenClub.fn_SMSScadenzaDocumento (@Sesso,@LastName,@expDate,@MemberTypeID)
	set @buffer = @buffer + '****Sending to Nr. ' + @SMSNumber  + '
' + @message + '
**** len ' + cast(len(@message) as varchar(32)) +'

'
	set  @recp = @SMSNumber --not valid for smskdev.it + ':' + cast(@CustomerID as varchar(16))

/*	set @msg = 'OK'*/
	exec GeneralPurpose.usp_SendSMS 
			@recp,
			@message, 
			@msg output
			
	if @msg = 'OK'
	begin
		set @buffer = @buffer + 'Spedito con success al SMS ' + @SMSNumber + ' ' + @LastName +'


'
	end
	ELSE
	BEGIN
		set @buffer = @buffer + 'Errore in spedizione al SMS ' + @SMSNumber + ' ' + @LastName + '
Causa: '	+ @msg 
  		SET @allOK = 0
	END  
	set @c = @c + 1
	FETCH NEXT FROM reg_cursor INTO @CustomerID,@LastName, @Sesso,@expDate,@SMSNumber,@MemberTypeID
END
set @ret = CURSOR_STATUS ('global','reg_cursor')
if @ret > -3
begin
	--print 'deallocting reg_cursor'
	DEALLOCATE reg_cursor
end

if @c = 0
begin
	set @message = 'Nessuna scadenza documenti AdmiralClub per il giorno ' + convert(varchar(32),GetDate() + 7,106)
	set @buffer = @message
end
else
	set @message = 'Spediti ' + cast(@c as varchar(16)) + ' sms di scadenza documenti AdmiralClub per il giorno ' + convert(varchar(32),GetDate() + 7,106)



IF @allOK = 0
	SET @message = 'ERRORE in Spedizione SMS Scadenza documenti'

exec msdb.dbo.[sp_send_dbmail]
   @recipients                 = 'itservice@cmendrisio.office.ch', 
   @subject                    = @message,
   @body                       = @buffer
   

declare @attribs varchar(4096)
select @attribs = 
	'DocumentiScaduti=''' + CAST(@c as varchar(32)) + '''' +
	' TimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' 
--print @attribs
execute [GeneralPurpose].[usp_BroadcastMessage] 'SentSMSScadenzaDocumenti',@attribs

GO
DENY EXECUTE ON  [GoldenClub].[msp_SendSMSScadenzaDocumenti] TO [FloorUsage]
GO
