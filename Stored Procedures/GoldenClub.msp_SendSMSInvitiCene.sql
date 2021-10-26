SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[msp_SendSMSInvitiCene]
AS


DECLARE 
@creditsPrima float,
@creditsDopo  float,
@vCreditsPrima varchar(256),
@vCreditsDopo varchar(256)


EXECUTE [SQLWebAPI].[usp_CheckCredit] 	@vCreditsPrima OUTPUT,	@creditsPrima OUTPUT

--print @vCreditsPrima
DECLARE @TimeStampUTC DATETIME,
@gamingdate DATETIME,
@smsSent INT


SET @TimeStampUTC = GETUTCDATE()
set @gamingdate = [GeneralPurpose].[fn_GetGamingDate] (@TimeStampUTC,1,DEFAULT)



--have a look if we have iniviti in 2 days
SET @gamingdate = DATEADD(DAY,2,@gamingdate)

PRINT 'Spedizione inviti cene del ' + CONVERT(VARCHAR(32),@GamingDate,105)
DECLARE @ret INT
SET @ret = CURSOR_STATUS ('global','inviti_cursor')
--print 'CURSOR_STATUS returned ' + cast(@ret as varchar)
IF @ret > -3
BEGIN
--	print 'deallocting inviti_cursor'
	DEALLOCATE inviti_cursor
END

DECLARE inviti_cursor CURSOR
   FOR
SELECT i.InvitoID, 
	m.GoldenClubCardID,
	[GeneralPurpose].[fn_ProperCase](c.LastName,DEFAULT,DEFAULT) as LName, 
	[GeneralPurpose].[fn_ProperCase](c.FirstName,DEFAULT,DEFAULT) as FName,
	[GoldenClub].[fn_InvitoCena] (InvitoID) AS Invito,
	m.SMSNumber
FROM GoldenClub.tbl_InvitiCene i
	INNER JOIN GoldenClub.tbl_Members m ON m.CustomerID = i.CustomerID
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = i.CustomerID
WHERE i.GamingDate = @gamingdate
AND m.CancelID IS NULL 
AND m.GoldenClubCardID IS NOT NULL
AND m.SMSNumber IS NOT NULL
AND m.GoldenParams & 1 = 0 --the customer did not disable sms
AND m.GoldenParams & 2 = 2 --sms has been successfully verified
AND m.GoldenParams & 256 = 256  --enabled to be invited for cene

OPEN inviti_cursor
DECLARE @buffer VARCHAR(8000)
SET @buffer =  ''
DECLARE @buffer2 VARCHAR(5000)
SET @buffer2 =  ''

DECLARE @message VARCHAR(512)
DECLARE @msg  VARCHAR(MAX)
DECLARE @SMSNumber VARCHAR(256)
declare @LastName  Varchar(256)
declare @FirstName  Varchar(256)
declare @CardID int
DECLARE @InvitoID INT
DECLARE @c INT
DECLARE @r INT
DECLARE @allOK INT
DECLARE @recp VARCHAR(256)
DECLARE @err INT

SET @c = 0
SET @r = 0
SET @allOK = 1

FETCH NEXT FROM inviti_cursor INTO @InvitoID,@CardID,@LastName,@FirstName,@message,@SMSNumber
WHILE (@@FETCH_STATUS <> -1 AND @r = 0)
BEGIN

	SET @buffer = @buffer + '****Sending to Nr. ' + @SMSNumber  + '
'

/*
	test a gigi
	
	declare @msg  Varchar(max)
	declare @message varchar(512)
	set @message =  [GoldenClub].[fn_InvitoCena] (30341) --un invito del 17.02.2015 sig.r falzea
	exec [SMSkdev].usp_SendSMS
		'393200552824',
		@message,
		@msg output
	print @msg
*/

	SET  @recp = @SMSNumber --+ ':' + cast(@CustomerID as varchar(16))

	EXEC [GeneralPurpose].[usp_SendSMS]	@recp,@message,@msg OUTPUT

	IF @msg = 'OK'
	BEGIN
		--mark the hour we sent the sms
		BEGIN TRANSACTION updateInviti
		UPDATE GoldenClub.tbl_InvitiCene SET [SpedizioneSMSUTC] = @TimeStampUTC WHERE InvitoID = @InvitoID
		SELECT @err = @@ERROR 
		IF (@ERR <> 0) 
			ROLLBACK TRANSACTION updateInviti 
		ELSE
 			COMMIT TRANSACTION updateInviti 

		SET @buffer = @buffer + 'Spedito con successo al SMS ' + @SMSNumber + ' ' + @LastName + ' ' + @FirstName + ' carta ' + CAST(@cardID AS VARCHAR(32))+'


'
		SET @buffer2 = @buffer2 + 'Invito cena ' + @LastName + ' ' + @FirstName + '(' + CONVERT(VARCHAR(32),@GamingDate,105) + ')' + ' SMS ' + @SMSNumber  + ' carta ' + CAST(@cardID AS VARCHAR(32))+'
	
'			
	END
	ELSE
	BEGIN
		SET @buffer = @buffer + 'Errore in spedizione al SMS ' + @SMSNumber + ' ' + @LastName + ' ' + @FirstName + ' carta ' + CAST(@cardID AS VARCHAR(32))+ '
Causa:'	+ @msg + '


' 
		SET @buffer2 = @buffer2 + 'ERRORE in spedizione SMS: Invito cena ' + @LastName + ' ' + @FirstName + '(' + CONVERT(VARCHAR(32),@GamingDate,105) + ')' + ' SMS ' + @SMSNumber  + ' carta ' + CAST(@cardID AS VARCHAR(32))+'
	
'
		SET @allOK = 0
	END
	SET @c = @c + 1
	FETCH NEXT FROM inviti_cursor INTO @InvitoID,@CardID,@LastName,@FirstName,@message,@SMSNumber
END
SET @ret = CURSOR_STATUS ('global','inviti_cursor')
IF @ret > -3
BEGIN
	--print 'deallocting inviti_cursor'
	DEALLOCATE inviti_cursor
END
SET @Lastname = 'Sent ' + CAST(@c AS VARCHAR(16)) + ' sms di invito cena'

IF @c = 0
BEGIN
	SET @message = 'Nessun Invito cena GoldenClub per il giorno ' + CONVERT(VARCHAR(32),@gamingdate,106)
	SET @buffer = @message
	SET @buffer2 = @message
END
ELSE
	SET @message = 'Spediti ' + CAST(@c AS VARCHAR(16)) + ' sms di invito cena GoldenClub per il giorno ' + CONVERT(VARCHAR(32),@gamingdate,106)
PRINT @message 
--print @buffer

EXECUTE [SQLWebAPI].[usp_CheckCredit] 	@vCreditsDopo OUTPUT,	@creditsDopo OUTPUT


DECLARE @avviso NVARCHAR(4000)
SET @avviso	=	@message + '
Credits prima: ' + @vCreditsPrima	 + '
Credits dopo: ' + @vCreditsDopo

/*avvisami dell'avvenuta spedizione*/
EXEC [SQLWebAPI].usp_SendSMS 
		'393200552824',
		@avviso, 
		@msg OUTPUT


/*manda anche le mail dell'avvenuta spedizione*/

IF @allOK = 0
	SET @message = 'ERRORE in Spedizione SMS Invito Cena'

EXEC msdb.dbo.[sp_send_dbmail]
   @recipients                 = 'itservice@cmendrisio.office.ch', 
   @subject                    = @message,
   @body                       = @buffer


EXEC msdb.dbo.[sp_send_dbmail]
   @recipients                 = 'goldenclub@cmendrisio.office.ch', 
   @subject                    = @message,
   @body                       = @buffer2




DECLARE @attribs VARCHAR(4096)
SELECT @attribs = 
	'Inviti=''' + CAST(@c AS VARCHAR(32)) + '''' +
	' TimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead]( GeneralPurpose.fn_UTCToLocal(1,@TimeStampUTC)) + '''' +
	' TimeUTC=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampUTC) + '''' 
 
EXECUTE [GeneralPurpose].[usp_BroadcastMessage] 'SentSMSInvitiCena',@attribs
GO
