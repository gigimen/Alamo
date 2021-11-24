SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [GeneralPurpose].[usp_EmailVisitatoriPerCKey] 
@rec varchar(max),
@cc varchar(max) = null,
@bcc varchar(max) = null
as
/*


execute [GeneralPurpose].[usp_EmailVisitatoriPerCKey]  'l.menegolo@casinomendrisio.ch',null,null

declare 
@final bit,
@rec varchar(max),
@cc varchar(max),
@bcc varchar(max)

set @final = 1

set @rec = 'lmenegolo@cmendrisio.office.ch'
set @cc = null
set @bcc = null
--*/

declare
@Gaming DATETIME,
@TimeStampLoc datetime
set @TimeStampLoc = GETDATE()
select @Gaming =  GeneralPurpose.fn_GetGamingDate(@TimeStampLoc,0,20)
/*
SELECT td = CONVERT(VARCHAR(16),GamingDate,105),       '',  
                    td =giorno, '',  
                    td = ora, '',  
                    td = EntrateTotali, '',  
                    td = Uscite, '' , 
                    td = Sum(Saldo) over(order by ix), ''  
              FROM [Snoopy].[fn_VisiteOrarie] (@gaming) 
              FOR XML PATH('tr'), TYPE 
--SET @gaming ='10.23.2020'

*/

DECLARE @tableHTML  NVARCHAR(MAX) ,@SUBJECT varchar(2048)
SET @SUBJECT = 'Visite per ora per CKEY ' + CONVERT(VARCHAR(16),@gaming,105)
 
SET @tableHTML =  
    N'<H1>' + @SUBJECT + '</H1>' +  
    N'<table border="1">' +  
    N'<tr><th>GamingDate</th><th>Giorno</th>' +  
    N'<th>Ora</th><th>CKey1</th><th>CKey2</th><th>Ckey3</th><th>Tot Entrate</th><th>Uscite</th><th>Presenze</th></tr>' +  
    CAST ( ( SELECT td = CONVERT(VARCHAR(16),GamingDate,105),       '',  
                    td = giorno, '',  
                    td = ora, '',  
                    td = CKEY1, '',  
                    td = CKEY2, '' , 
                    td = CKEY3, '' , 
                    td = Entrate, '' , 
                    td = Uscite, '' , 
                    td = Sum(Saldo) over(order by ix), ''  
              FROM [Snoopy].[fn_VisiteOrarieByCKEY] (@gaming) 
              FOR XML PATH('tr'), TYPE   
    ) AS NVARCHAR(MAX) ) +  
    N'</table>' ;  

--print @tableHTML


EXEC msdb.dbo.[sp_send_dbmail]
	@recipients                 = @rec, 
	@subject                    = @SUBJECT,
	@body                       = @tableHTML,
    @body_format				= 'HTML', 
    @copy_recipients			= @cc,
    @blind_copy_recipients	= @bcc
GO
