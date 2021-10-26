SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [GeneralPurpose].[usp_EmailTransazioniDeposito] 
@rec varchar(max),
@cc varchar(max) = null,
@bcc varchar(max) = 'itservice@cmendrisio.office.ch'
as

declare @body nvarchar(max),@sub nvarchar(max),@gaming datetime


set @gaming = [generalpurpose].fn_GetGamingLocalDate2(
			GetUTCDate(),
			Datediff(hh,GetUTCDAte(),GetDate()),
			7 --cassa centrale
	)
--set @gaming = '6.21.2020'

select @body = '<div align="center"><font color=#996666 size=14pt> Rapporto transazioni di deposito </font><br><font color=#996666 size=14pt>GamingDate ' +
	+[GeneralPurpose].[fn_FormatDate](@gaming)
	+ '</font><br>
	<table border=1>
	'
	+'<tr>'
	+'<td width=200 height=40><div align="left"><font color=#339966 size=14pt>Cognome</font></div></td>'
	+'<td width=200 height=40><div align="left"><font color=#339966 size=14pt>Nome</font></div></td>'
	+'<td width=100 height=40><div align="right"><font color=#339966 size=14pt>Importo</font></div></td>'
	+'<td width=180 height=40><div align="center"><font color=#339966 size=14pt>Ora deposito</font></div></td>'
	+'<td width=180 height=40><div align="center"><font color=#339966 size=14pt>Ora prelievo</font></div></td>'
	+'</tr>'
--print @body



DECLARE @riga NVARCHAR(MAX)
DECLARE depcur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR SELECT N'
	<tr>'
	+'<td ><div align="left"><font size=11pt>'	+ [LastName]	+'</font></div></td>'
	+'<td ><div align="left"><font size=11pt>'	+ [FirstName]	+'</font></div></td>'
	+'<td ><div align="right"><font size=11pt>'	+ cast([Importo] as nvarchar(16)) +'</font></div></td>'
	+'<td ><div align="center"><font size=11pt>'	+ [GeneralPurpose].[fn_FormatDateTime]([DepOnTransTime]) + '</font></div></td>'
	+'<td ><div align="center"><font size=11pt>'	+ case when [DepOffTransTime] is null then '' else  [GeneralPurpose].[fn_FormatDateTime]([DepOffTransTime]) end + '</font></div></td>'
	+'</tr>'
FROM Snoopy.vw_AllDepositi
where DepOnGamingdate = @gaming
or DepOffGamingdate = @gaming
or DepOffGamingdate is null
order by [DepOnTransTime] asc


OPEN depcur

FETCH NEXT FROM depcur INTO @riga 
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @body += @riga
FETCH NEXT FROM depcur INTO @riga 
END

CLOSE depcur
DEALLOCATE depcur


--print @body

SELECT @body += 
	'
	<tr>'
	+'<td ><div align="left"><font size=11pt>' + cast(Isnull(COUNT(*),0) as varchar(12)) +' depositi correnti</font></div></td>'
	+'<td ></td>'
	+'<td ><div align="right"><font size=11pt>'+ cast(Isnull(sum(Importo),0) as varchar(12)) + '</font></div></td>'
	+'<td ></td>'
	+'<td ></td>'
	+'</tr>'
	+'</table></div>'
FROM Snoopy.vw_AllDepositi
where DepOffGamingdate is null

--print len(@body)

DECLARE @RC int

set @sub =    'Transazioni di deposito gamingdate ' + [GeneralPurpose].[fn_FormatDate] (@gaming)

EXECUTE @RC = [GeneralPurpose].[usp_EmailMessageEx] 
	@sub
  ,@body
  ,'lmenegolo@cmendrisio.office.ch'--'mmarinari@cmendrisio.office.ch'
  ,null--'lantonini@cmendrisio.office.ch;pmastria@cmendrisio.office.ch'
  ,null--'it.service@cmendrisio.office.ch'
  ,null--null

--print @RC
GO
