SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [GoldenClub].[msp_SendCompleanni]
AS


DECLARE 
@creditsPrima float,
@creditsDopo  float,
@vCreditsPrima varchar(256),
@vCreditsDopo varchar(256)



EXECUTE [SQLWebAPI].usp_CheckCredit @vCreditsPrima output,	@creditsPrima output

--print @vCreditsPrima
declare @TimeStampLoc datetime
DECLARE @smsSent int,@day int,@month int


set @TimeStampLoc = getdate()
set @day = DatePart(dd,GetDate())
set @month = DatePart(mm,GetDate()) 

declare @ret int
set @ret = CURSOR_STATUS ('global','reg_cursor')
--print 'CURSOR_STATUS returned ' + cast(@ret as varchar)
if @ret > -3
begin
--	print 'deallocting reg_cursor'
	DEALLOCATE reg_cursor
end
DECLARE reg_cursor CURSOR
   FOR
SELECT
	CustomerID, 
	GoldenClubCardID,
	[GeneralPurpose].[fn_ProperCase](LastName,DEFAULT,DEFAULT) as LName, 
	[GeneralPurpose].[fn_ProperCase](FirstName,DEFAULT,DEFAULT) as FName,
	BirthDate, 
	Sesso,
	SMSNumber
FROM         GoldenClub.vw_AllGoldenMembers
WHERE     DatePart(dd,BirthDate) = @day and 
	      DatePart(mm,BirthDate) = @month                 
AND gccancelid is null 
AND GoldenClubCardID IS NOT null
AND smsnumber is not null
AND SMSNumberDisabled = 0 --the customer did not disable sms
AND SMSNumberChecked = 1 --sms has been successfully verified
AND GoldenParams & 512 = 512  --enabled to be invited for birthday

OPEN reg_cursor
declare @buffer varchar(8000)
set @buffer =  ''
declare @buffer2 varchar(5000)
set @buffer2 =  ''
declare @message varchar(512)
declare @LastName  Varchar(256)
declare @FirstName  Varchar(256)
declare @msg  Varchar(max)
declare @birth	datetime
declare @Sesso	bit
declare @SMSNumber Varchar(256)
declare @CustomerID int
declare @CardID int
declare @c int
declare @r int
declare @allOK INT
declare @recp varchar(256)
set @c = 0
set @r = 0
SET @allOK = 1

FETCH NEXT FROM reg_cursor INTO @CustomerID,@CardID,@LastName,@FirstName,@Birth,@Sesso,@SMSNumber
WHILE (@@FETCH_STATUS <> -1 and @r = 0)
BEGIN
	set @message =  [GoldenClub].[fn_SMSCompleanno] (@Sesso,@LastName)
	set @buffer = @buffer + '****Sending to Nr. ' + @SMSNumber  + '
'

/*
	test a gigi
	
	declare @msg  Varchar(max)
	declare @message varchar(512)
	set @message =  [GoldenClub].[fn_SMSCompleanno] (1,'Soru')
	exec [SMSkdev].usp_SendSMS
		'+3200552824',
		@message,
		@msg output
	print @msg
*/

	set  @recp = @SMSNumber --+ ':' + cast(@CustomerID as varchar(16))

	exec [GeneralPurpose].[usp_SendSMS]
		@recp,
		@message, 
		@msg output

	if @msg = 'OK'
	begin
		set @buffer = @buffer + 'Spedito con successo al SMS ' + @SMSNumber + ' ' + @LastName + ' ' + @FirstName + ' carta ' + cast(@cardID as varchar(32))+'


'
		set @buffer2 = @buffer2 + 'Compleanno ' + @LastName + ' ' + @FirstName + '(' + convert(varchar(32),@Birth,105) + ')' + ' SMS ' + @SMSNumber  + ' carta ' + cast(@cardID as varchar(32))+'
	
'			
	END
	ELSE
	BEGIN
		set @buffer = @buffer + 'Errore in spedizione al SMS ' + @SMSNumber + ' ' + @LastName + ' ' + @FirstName + ' carta ' + cast(@cardID as varchar(32))+ '
Causa:'	+ @msg + '


' 
		set @buffer2 = @buffer2 + 'ERRORE in spedizione SMS: Compleanno ' + @LastName + ' ' + @FirstName + '(' + convert(varchar(32),@Birth,105) + ')' + ' SMS ' + @SMSNumber  + ' carta ' + cast(@cardID as varchar(32))+'
	
'
		SET @allOK = 0
	END
	set @c = @c + 1
	FETCH NEXT FROM reg_cursor INTO @CustomerID,@CardID,@LastName,@FirstName,@Birth,@Sesso,@SMSNumber
END
set @ret = CURSOR_STATUS ('global','reg_cursor')
if @ret > -3
begin
	--print 'deallocting reg_cursor'
	DEALLOCATE reg_cursor
end
set @Lastname = 'Sent ' + cast(@c as varchar(16)) + ' sms di compleanno'
if @c = 0
begin
	set @message = 'Nessun compleanno GoldenClub per il giorno ' + cast(@day as varchar(16)) + '-' + cast(@month as varchar(16)) + '-' + cast(DatePart(yy,GetDate())  as varchar(16)) 
	set @buffer = @message
	set @buffer2 = @message
end
else
	set @message = 'Spediti ' + cast(@c as varchar(16)) + ' sms di compleanno GoldenClub per il giorno ' + cast(@day as varchar(16)) + '-' + cast(@month as varchar(16)) + '-' + cast(DatePart(yy,GetDate())  as varchar(16)) 
print @message 
--print @buffer

execute [SQLWebAPI].[usp_CheckCredit] 	@vCreditsDopo output,	@creditsDopo output


declare @avviso nvarchar(4000)
set @avviso	=	@message + '
Credits prima: ' + @vCreditsPrima	 + '
Credits dopo: ' + @vCreditsDopo

/*avvisami dell'avvenuta spedizione*/
exec [SQLWebAPI].usp_SendSMS 
		'+393200552824',
		@avviso, 
		@msg output


/*manda anche le mail dell'avvenuta spedizione*/

IF @allOK = 0
	SET @message = 'ERRORE in Spedizione SMS Compleanni'

exec msdb.dbo.[sp_send_dbmail]
   @recipients                 = 'itservice@cmendrisio.office.ch', 
   @subject                    = @message,
   @body                       = @buffer
   
exec msdb.dbo.[sp_send_dbmail]
   @recipients                 = 'goldenclub@cmendrisio.office.ch', 
   @subject                    = @message,
   @body                       = @buffer2





declare @attribs varchar(4096)
select @attribs = 
	'Compleanni=''' + CAST(@c as varchar(32)) + '''' +
	' TimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' 
 
execute [GeneralPurpose].[usp_BroadcastMessage] 'SentSMSCompleanni',@attribs
GO
