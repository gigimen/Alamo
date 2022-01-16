SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [GeneralPurpose].[usp_EmailCasinoResults] 
@final BIT,
@rec VARCHAR(MAX),
@cc VARCHAR(MAX) = NULL,
@bcc VARCHAR(MAX) = 's.tettamanti@casinomendrisio.ch;l.menegolo@casinomendrisio.ch'
AS
/*




declare 
@final bit,
@rec varchar(max),
@cc varchar(max),
@bcc varchar(max)

set @final = 1

set @rec = 'l.menegolo@casinomendrisio.ch'
set @cc = null
set @bcc = null
--*/

declare

@GamingDate datetime,
@body nvarchar(max),
@TimeStampLoc datetime,
@subject varchar(64)

set @TimeStampLoc = GETDATE()
select @GamingDate = GeneralPurpose.fn_GetGamingDate(@TimeStampLoc,0,12)
--SET @GamingDate = '08.28.2020'
--PRINT @GamingDate

--set @final = 0
set @subject =  left(convert(nvarchar(32),@TimeStampLoc,13),len(convert(nvarchar(32),@TimeStampLoc,13)) - 7)
--SET @ora = STR(DATEPART(HOUR,@TimeStampLoc),2,0) + ':' + CAST(DATEPART(MINUTE,@TimeStampLoc) AS VARCHAR(4))
--print @ora
--select * FROM [Snoopy].[vw_DailyVisitors] WHERE GamingDate = @GamingDate


select	@body = N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii"><title>Monitor Alarm</title>
    <style type="text/css">
    body
    {
        font-family: "Helvetica", Arial, sans-serif;
        color:#000000;
        margin:5px;
    }
    div.main_title
    {
        color:#077dc5;
        font-weight: bold;
        font-size:16pt;
        width:100%;
    }
    .server_name
    {
        font-weight: bold;
        height: 30px;
        width: 100%;
        font-size:14pt;
        background-color: #0888d8;
        color: white;
        vertical-align:middle;
    }
    .first_column
    {
         width: 120px;
         font-weight: bold;
         color: #404040;
    }
    .second_column
    {
         width: 120px;
        font-weight: normal;
         font-size: 11pt;
         background-color:white;
    }
    .second_column_bse
    {
          width: 200px;
       font-weight: bold;
         font-size: 11pt;
         background-color:#FFE0E0;
    }
    .warning_cell
    {
         background-color: #ffc000;
         font-weight: normal;
         font-size: 11pt;
    }
    .error_cell
    {
         background-color: #F16D56;
         font-weight: normal;
         font-size: 11pt;
    }
    .info_cell
    {
         background-color: #6699ff;
         font-weight: normal;
         font-size: 11pt;
    }
    .resolved_cell
    {
         background-color: #66cc66;
         font-weight: normal;
         font-size: 11pt;
    }
    .acknowledged_cell
    {
         background-color: #ccc;
         font-weight: normal;
         font-size: 11pt;
    }
    .main_table
    {
        width: 400px;
        padding: 3px;
        font-size: 11pt;
    }
    .kb_table
    {
        width:800px;
        padding: 0px;
        border:0; 
        
    }
    .kb_table td
    {
        border-bottom: 1px solid #cccccc;
        padding-bottom: 5px;
        padding-top: 5px;
        color: #404040;
    }
    .first_column_visite_head
    {
        width: 130px;
         background-color: #66cc66;
        font-weight: bold;
 		text-align: center;
       font-size: 11pt;
    }
    .second_column_visite_head
    {
        width: 50px;
         background-color: #66cc66;
        font-weight: bold;
		text-align: center;
        font-size: 11pt;
    }
    .third_column_visite_head
    {
        width: 50px;
         background-color: #66cc66;
        font-weight: bold;
		text-align: center;
        font-size: 11pt;
    }
    .first_column_visite
    {
        width: 130px;
        font-weight: normal;
 		text-align: center;
       font-size: 11pt;
    }
    .second_column_visite
    {
        width: 50px;
        font-weight: normal;
		text-align: center;
        font-size: 11pt;
    }
    .third_column_visite
    {
        width: 50px;
        font-weight: normal;
		text-align: center;
        font-size: 11pt;
    }
    </style>
</head>
<body>
    <div class="main_title">GamingDate: ' + convert(nvarchar(32),@GamingDate,103) + '</div><br>
    <table border="0" cellspacing="1" cellpadding="0" class="main_table">
        <tr>
            <td class="resolved_cell">&nbsp;Data e Ora:</td>
            <td class="second_column">' + @subject + '</td>
       </tr>
        <tr style="">
            <td class="resolved_cell">Visite:</td>
            <td class="second_column">' + CAST([visite] AS VARCHAR(32)) +  '</td>
        </tr>
        <tr style="">
            <td class="resolved_cell">Entrate:</td>
            <td class="second_column">' + CAST([entrate] AS VARCHAR(32)) +  '</td>
        </tr>
        <tr style="">
            <td class="resolved_cell">Ultima visita:</td>
            <td class="second_column">' + left(convert(nvarchar(32),[ultimaVisita],13),len(convert(nvarchar(32),[ultimaVisita],13)) - 7) + '</td>
        </tr>
    </table>
	<br>'
FROM [Snoopy].[vw_DailyVisitors]
WHERE GamingDate = @GamingDate


PRINT @body

select	@body += N'
    <table border="0" cellspacing="0" cellpadding="0" style="border-bottom:1px; width: 400px;">
        <tr>
            <td class="server_name">&nbsp;Tavoli</td>
        </tr>
    </table>'

if @final = 1
begin

/*
declare

@GamingDate datetime,
@body nvarchar(max),
@TimeStampLoc datetime,
@ora varchar(64)

set @gamingdate = '6.7.2020'

--*/

--calcola ora dell'ultimo gioco sulle slot
	SELECT @TimeStampLoc = [StateTimeLoc] FROM [Accounting].[vw_AllProgress]
	WHERE [StateTimeUTC] = 
	(
		SELECT MAX([StateTimeUTC]) FROM [Accounting].[vw_AllProgress]
		where GamingDate = @GamingDate
	)
	--select @TimeStampLoc

	IF @TimeStampLoc IS NOT NULL
    BEGIN
		SET @subject =  left(convert(nvarchar(32),@TimeStampLoc,13),len(convert(nvarchar(32),@TimeStampLoc,13)) - 7)
		SELECT	@body += N'
			<tr style="">
				<td class="first_column">Ultimo sotfcount:</td>
				<td class="second_column">' + @subject + '</td>
			</tr>'
	END
END


--PRINT @body


/*
declare

@GamingDate datetime,
@body nvarchar(max),
@TimeStampLoc datetime,
@ora varchar(64)

set @gamingdate = '6.7.2020'

set @body = ''

--*/


select	@body += N'<table border="0" cellspacing="1" cellpadding="0" class="main_table">
'
SELECT @body += N'
        <tr style="">
            <td class="first_column">Tavoli aperti:</td>
            <td class="second_column">'+ cast ( count(distinct a.Tag) as varchar(16) ) + '</td>
        </tr>
        <tr style="">
            <td class="first_column">Drop stimato(kCHF):</td>
            <td class="second_column">'+ cast (isnull(sum(a.[Value]),0) / 1000.0 as varchar(16) ) + '</td>
        </tr>'
/*
declare

@GamingDate datetime,
@body nvarchar(max),
@TimeStampLoc datetime,
@ora varchar(64)

set @gamingdate = '6.7.2020'

select count(distinct a.Tag),isnull(sum(a.[Value]),0) 
--*/

from 
(

	SELECT 
		lf.LifeCycleID,
		p.DenoID,
		MAX(p.StateTime) AS MRTime
	FROM Accounting.tbl_Progress p
		INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = p.LifeCycleID
		INNER JOIN CasinoLayout.Stocks st ON lf.StockID = st.StockID
	WHERE lf.GamingDate = @GamingDate
			and st.StockTypeID = 1
			and p.DenoID = 11
	GROUP BY lf.LifeCycleID,p.DenoID
) p
inner join Accounting.vw_AllProgress a on a.LifeCycleID = p.LifeCycleID and a.StateTimeUTC = p.MRTime and a.DenoID = p.DenoID

print @body

--risultato AR
select	@body += N'
        <tr style="">
            <td class="first_column">BSE AR (kCHF):</td>
            <td class="second_column">'+ cast (isnull(sum([Value]),0) / 1000.0 as varchar(16) ) + '</td>
        </tr>'
--select *  
FROM [Accounting].[vw_CurrRisultatoDeiTavoli]
where DenoID = 23 and left(Tag,2) = 'AR'

--risultato BJ
select	@body += N'
        <tr style="">
            <td class="first_column">BSE BJ (kCHF):</td>
            <td class="second_column">'+ cast (isnull(sum([Value]),0) / 1000.0 as varchar(16) ) + '</td>
        </tr>'
--select *  
FROM [Accounting].[vw_CurrRisultatoDeiTavoli]
where DenoID = 23 and left(Tag,2) = 'BJ'


--risultato PB
select	@body += N'
        <tr style="">
            <td class="first_column">BSE PB (kCHF):</td>
            <td class="second_column">'+ cast (isnull(sum([Value]),0) / 1000.0 as varchar(16) ) + '</td>
        </tr>'
--select *  
FROM [Accounting].[vw_CurrRisultatoDeiTavoli]
where DenoID = 23 and left(Tag,2) = 'PB'

--risultato UT
select	@body += N'
        <tr style="">
            <td class="first_column">BSE UTH (kCHF):</td>
            <td class="second_column">'+ cast (isnull(sum([Value]),0) / 1000.0 as varchar(16) ) + '</td>
        </tr>'
--select *  
FROM [Accounting].[vw_CurrRisultatoDeiTavoli]
where DenoID = 23 and left(Tag,2) = 'UT'

--risultato SB
select	@body += N'
        <tr style="">
            <td class="first_column">BSE SB (kCHF):</td>
            <td class="second_column">'+ cast (isnull(sum([Value]),0) / 1000.0 as varchar(16) ) + '</td>
        </tr>'
--select *  
FROM [Accounting].[vw_CurrRisultatoDeiTavoli]
where DenoID = 23 and left(Tag,2) = 'SB'

--risultato globale
select	@body += N'
        <tr style="">
            <td class="first_column">BSE (kCHF):</td>
            <td class="second_column_bse">'+ cast (isnull(sum([Value]),0) / 1000.0 as varchar(16) ) + '</td>
        </tr>
		</table>'
FROM [Accounting].[vw_CurrRisultatoDeiTavoli]
where DenoID = 23

--visite orarie
select	@body += N'
	<br> <div class="main_title">Visite orarie</div><br>
    <table border="0" cellspacing="0" cellpadding="0" style="border-bottom:1px; width:600px;">
        <tr>
            <td class="second_column_visite_head">Giorno</td>
            <td class="second_column_visite_head">Ora</td>
            <td class="second_column_visite_head">Entrate</td>
            <td class="second_column_visite_head">Uscite</td>
            <td class="second_column_visite_head">Presenze</td>
        </tr>'

DECLARE @riga NVARCHAR(MAX)
DECLARE visitcur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR SELECT N'
        <tr style="">
            <td class="first_column_visite">' + CAST(giorno AS VARCHAR(8)) + '</td>
            <td class="second_column_visite">' + CAST(ora AS VARCHAR(8)) + '</td>
            <td class="third_column_visite">' + CAST([EntrateTotali] AS VARCHAR(8)) + '</td>
            <td class="third_column_visite">' + CAST([Uscite] AS VARCHAR(8)) + '</td>
            <td class="third_column_visite">' + CAST(SUM(Saldo) OVER(ORDER BY ix) AS VARCHAR(8)) + '</td>
        </tr>'

/*
declare @GamingDate datetime
set @gamingdate = '12.11.2021'
select * , Sum(Saldo) over(order by ix) as Presenze
--*/
FROM [Reception].[fn_VisiteOrarie] (@GamingDate)
WHERE ix <= 3 OR entratetotali <> 0 OR uscite <> 0
OPEN visitcur

FETCH NEXT FROM visitcur INTO @riga 
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @body += @riga
FETCH NEXT FROM visitcur INTO @riga 
END

CLOSE visitcur
DEALLOCATE visitcur



SELECT	@body += N'</table>
</BODY>
</HTML>'

SELECT @body AS body

SET @subject = 'Risultato parziale Casinò Mendrisio alle ore ' +  CAST(DATEPART(HOUR,GETDATE()) AS VARCHAR(16))
IF @final = 1
	SET @subject = 'Risultato finale Casinò Mendrisio del gamingdate '  + CONVERT(NVARCHAR(32),@GamingDate,103)

EXEC [GeneralPurpose].[usp_EmailMessageEx] 
					@subject,
					@body, 
					@rec, --'l.menegolo@casinomendrisio.ch',
					@cc,--'s.tettamanti@casinomendrisio.ch',
					@bcc,
					'tavoli@casinomendrisio.ch'
GO
