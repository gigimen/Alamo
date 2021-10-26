SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_SendSMSPremioArrivato]
@AssegnazionePremioID int,
@justSendSMS	bit,
@msg varchar(256) OUTPUT
AS
if @AssegnazionePremioID is null or not exists 
(
		select AssegnazionePremioID
		from Marketing.tbl_AssegnazionePremi
		where AssegnazionePremioID = @AssegnazionePremioID 
)
begin
	raiserror('Invalid AssegnazionePremioID (%d) specified',16,1,@AssegnazionePremioID)
	return 1
END

DECLARE @recp VARCHAR(64)
DECLARE @smsMessage VARCHAR(1024)



select @smsMessage = CASE WHEN c.Sesso = 1 THEN 'Gent. Sig.ra ' ELSE 'Egr. Sig. ' END + c.LastName + 
	' il suo premio ' + pro.FDescription + ' ' + p.FName + ' è disponibile al CAM.
Per il ritiro si rivolga al servizio guardaroba del casinó dalle 15.30 alle 24',
	@recp = g.SMSNumber
from Marketing.tbl_AssegnazionePremi ass
	INNER JOIN Marketing.tbl_OffertaPremi o ON o.OffertaPremioID = ass.OffertaPremioID
	INNER JOIN GoldenClub.tbl_Members g ON ass.CustomerID = g.CustomerID
	INNER JOIN Marketing.tbl_Premi p ON p.PremioID = o.PremioID
	INNER JOIN Marketing.tbl_Promozioni pro ON pro.PromotionID = o.PromotionID
	INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = g.CustomerID
where ass.AssegnazionePremioID = @AssegnazionePremioID 
	AND GoldenParams & 1 = 0 -- SMSNumber is not disabled
	AND g.SMSNumber IS NOT null


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_SendSMSPremioArrivato

BEGIN TRY  



	IF @justSendSMS = 0
	begin
		UPDATE Marketing.tbl_AssegnazionePremi 
			SET [SmsInviatoTimeStampUTC] = GETUTCDATE()
			where AssegnazionePremioID = @AssegnazionePremioID	
	END

	IF @smsMessage IS NOT NULL AND @smsMessage IS NOT NULL
	BEGIN    

	
		exec [GeneralPurpose].usp_SendSMS
				@recp,
				@smsMessage, 
				@msg OUTPUT
		
		SET @msg = 'OK'	

		if @msg <> 'OK'
		begin
			raiserror('Cannot send sms: %s',16,1,@msg)
		end	
	END
	ELSE
		SET @msg = 'SMS disable: message not sent'



	COMMIT TRANSACTION trn_SendSMSPremioArrivato

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_SendSMSPremioArrivato
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret

GO
