SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [GoldenClub].[usp_PromoteToGolden]
@CustomerID INT,
@PersonalClubCardID INT OUTPUT
AS

DECLARE --@cardID							INT,
		@params								INT
		--@recp								VARCHAR(256),
		--@sms								VARCHAR(1024)

/*controlla che il cliente sia un membro admiral,dragon e promuovilo al golden club*/
SELECT	@params					= GoldenParams,
		@PersonalClubCardID		= GoldenClubCardID
/*lm 1.5.2018: NIENTE CREAZIONE DELLA CARTA ADMIRAL: si tiene la sua!! 
		@cardID = GoldenClubCardID,
		@recp = SMSNumber --+ ':' + CAST(CustomerID AS VARCHAR(16))
*/
FROM GoldenClub.tbl_Members 
WHERE CustomerID = @CustomerID 
AND CancelID IS NULL 
AND GoldenClubCardID IS NOT NULL--the card must be linked
--and SMSNumber is not null		--must hace a valid sms number
AND MemberTypeID IN (2,3)		--must be a dragon or admiral Member

IF @params IS NULL 
BEGIN
	--lm:non fare niente:il cliente è gia un golden o non esiste proprio nel club!!
	--RAISERROR('Invalid CustomerID (%d) specified or customer is already a golden',16,1,@CustomerID)
	
	RETURN 0
END


DECLARE @defGoldParam INT
SELECT @defGoldParam = [DefaultGoldenParams] FROM GoldenClub.tbl_MemberTypes WHERE MemberTypeID = 1 --get golden default flags

SET @params |= @defGoldParam -- enable cene and compleanni

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_PromoteToGolden

BEGIN TRY  




	UPDATE GoldenClub.tbl_Members
		SET GoldenParams = @params,
		MemberTypeID = 1 --this is a full golden now
	WHERE CustomerID = @CustomerID

	/*lm 1.5.2018: NIENTE CREAZIONE DELLA CARTA ADMIRAL: si tiene la sua!! 
	SET @sms = 'Il CAM è lieto di poterLa annoverare tra i soci del GOLDEN CLUB.
	Il suo numero di carta è ' + CAST (@cardID AS VARCHAR(32))



	IF @MemberTypeID = 3 --for admiral members we have to create his personal card
	BEGIN

		execute	@ERR = GoldenClub.usp_CreateGoldenCard
			@CustomerID 		,
			@PersonalClubCardID 	output
		set @sms = 'Il CAM è lieto di poterLa annoverare tra i soci del GOLDEN CLUB.
	La sua nuova carta personale ' + CAST (@PersonalClubCardID as varchar(32)) + ' è stata mandata in produzione'
	END
	*/


	/*lm 1.5.2018: non piu spedizione dell'sms

	if @recp is not null and @params & 1 = 0 --smsenabled
	begin
		declare @msg varchar(max)
	
		exec GeneralPurpose.usp_SendSMS
				@recp,
				@sms, 
				@msg output
	end
	*/
	COMMIT TRANSACTION trn_PromoteToGolden

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_PromoteToGolden
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
