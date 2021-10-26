SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [GoldenClub].[usp_EventiDeliverNotification] 
@eventid int,
@CustomerID int,
@Delivered smallint,
@recp	varchar(32)
AS

--first check if customer is golden club member
if @CustomerID is null or not exists 
	(select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustomerID and GoldenClubCardID is not null and CancelID is null)
begin
	raiserror('%d is not a valid CustomerID or is not a Golden Club Member',16,1,@CustomerID)
	return 1
end



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EventiDeliverNotification

BEGIN TRY  


	
	if not exists(select CustomerID from GoldenClub.tbl_InvitoEventi where CustomerID = @CustomerID and EventoID = @eventid) 
		insert into GoldenClub.tbl_InvitoEventi
		 (EventoID,CustomerID,Delivered,Recipient) 
		values( @eventid,@CustomerID,@Delivered,@recp)
	ELSE
		update GoldenClub.tbl_InvitoEventi
		 SET Delivered=@Delivered,Recipient= @recp
		where CustomerID = @CustomerID and EventoID = @eventid

	--if delivered is OK and SMSNumber was not checked yet
	--mark it as if ok
	if @Delivered = 1 and exists (  
		select CustomerID from GoldenClub.tbl_Members 
		where (GoldenParams & 2 = 0)			--sms non checked yet
		and SMSNumber = @recp				--any customer with the same SMSNumber
	)
	begin
		update  GoldenClub.tbl_Members 
		set GoldenParams = GoldenParams | 2,
		SMSNumberCheckedTimestampUTC = GetUTCDate(),
		SMSNumberCheckedFromIPAddress = 'From Event ' + cast(@eventid as varchar(8)) + ' delivery notification'
		where SMSNumber = @recp
	END
	ELSE  --no delivered if marked ok set it to be checked
		IF  @Delivered = 0 AND EXISTS (  
		select CustomerID from GoldenClub.tbl_Members 
		where (GoldenParams & 2 = 2)			--sms checked
		and SMSNumber = @recp				--the same SMSNumber
		) 
		BEGIN
			update  GoldenClub.tbl_Members 
			set GoldenParams = GoldenParams & (~2), --unset smsnumbercheckd flag
			SMSNumberCheckedTimestampUTC = GetUTCDate(),
			SMSNumberCheckedFromIPAddress = 'From Event ' + cast(@eventid as varchar(8)) + ' delivery notification'
			where SMSNumber = @recp      
		END      


COMMIT TRANSACTION trn_EventiDeliverNotification

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EventiDeliverNotification
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
