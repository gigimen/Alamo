SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE  PROCEDURE [GeneralPurpose].[usp_EmailMessage] 
@sub varchar(255),
@bod varchar(max),
@rec varchar(max),
@from varchar(max)
AS

if @sub is null or LEN(@sub) = 0
begin
	raiserror('Must specify the subject',16,1)
	return(1)
end
/*
if @bod is null or len(@bod) = 0
begin
	raiserror('Must specify the body',16,1)
	return(1)
end
*/
if @rec is null or len(@rec) = 0
select @rec = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'MailAddressTo'
if @rec is null
begin
	raiserror('Errore in lettura recipients',16,1)
	return(1)
end

if @from is null or len(@from) = 0
	exec msdb.dbo.[sp_send_dbmail]
	   @recipients  = @rec, 
	   @subject     = @sub,
	   @body        = @bod,
	   @body_format= 'HTML'
else
	exec msdb.dbo.[sp_send_dbmail]
	   @recipients  = @rec, 
	   @subject     = @sub,
	   @body        = @bod,
	   @from_address= @from,
	   @body_format= 'HTML'
   
GO
