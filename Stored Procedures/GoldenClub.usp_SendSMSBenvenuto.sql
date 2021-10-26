SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [GoldenClub].[usp_SendSMSBenvenuto]
@CustomerID int,
@checkInvitoEventi int,
@msg varchar(256) output
AS

declare @MemberTypeID						int,
		@cardID								int,
		@URLBufferedDeliveryNotifications	varchar(1024),
		@URLDeliveryNotifications			varchar(1024),
		@URLUndeliveryNotifications			varchar(1024),
		@recp								varchar(16),
		@tranfRef							varchar(16),
		@sms								varchar(1024)

if @CustomerID is null or not exists 
(
		select CustomerID
		from GoldenClub.tbl_Members 
		where CustomerID = @CustomerID 
		and CancelID is null 
		and GoldenClubCardID is not null--the card must be linked
		and SMSNumber is not null		--must hace a valid sms number
)
begin
	raiserror('Invalid CustomerID (%d) specified or smsnumber is not defined',16,1,@CustomerID)
	return 1
end
--check id we have smsdisble flag
if exists (
	select CustomerID from GoldenClub.tbl_Members 
	where 
	CustomerID = @CustomerID  
	and GoldenParams & 1 = 1 -- SMSNumberDisabled
	)
begin
	raiserror('CustomerID (%d) has sms disabled ',16,1,@CustomerID)
	return 1
end
select  @MemberTypeID = MemberTypeID,
		@cardID = GoldenClubCardID,
		@recp = SMSNumber,
		@tranfRef = cast(CustomerID as varchar(16))
		from GoldenClub.tbl_Members 
		where CustomerID = @CustomerID 


/*if @MemberTypeID = 1 --golden
	set @sms = 'Il CAM è lieto di poterLa annoverare tra i soci del GOLDEN CLUB.
Il suo numero di carta è ' + CAST (@cardID as varchar(32))
ELSE if @MemberTypeID = 2 --dragon
	set @sms = 'Il CAM è lieto di poterLa annoverare tra i soci del DRAGON CLUB.
Il suo numero di carta è ' + CAST (@cardID as varchar(32))
else if @MemberTypeID = 3 --admiral
	*/set @sms = 'Il CAM è lieto di poterLa annoverare tra i soci dell''ADMIRAL CLUB.
Il suo numero di carta è ' + CAST (@cardID as varchar(32))



/*lm dal 23-04-2018: non richiediamo piu la richiesta di verifica di delivery
--sms di benvenuto with delivery notification

SELECT
		@URLBufferedDeliveryNotifications = [VarValue]
FROM [GeneralPurpose].[ConfigParams]
	  where [VarName] = 'URLBufferedDeliveryNotifications'

SELECT
		@URLDeliveryNotifications = [VarValue]
FROM [GeneralPurpose].[ConfigParams]
	  where [VarName] = 'URLDeliveryNotifications'

SELECT
		@URLUndeliveryNotifications = [VarValue]
FROM [GeneralPurpose].[ConfigParams]
	  where [VarName] = 'URLUndeliveryNotifications'

/*
print @recp
print @sms
print @URLBufferedDeliveryNotifications	
print @URLDeliveryNotifications		
print @URLUndeliveryNotifications		
	*/


exec [GeneralPurpose].usp_SendSMSWithDelivery 
			@recp,
			@tranfRef,
			@sms, 
			@URLBufferedDeliveryNotifications,	
	 		@URLDeliveryNotifications	,	
	 		@URLUndeliveryNotifications	,
			@msg output
*/

exec [GeneralPurpose].[usp_SendSMS]
			@recp,
			@sms, 
			@msg output

if @msg <> 'OK'
begin
	raiserror('Cannot send sms: %s',16,1,@msg)
	return 1
end	

if @checkInvitoEventi = 1
begin

	--if the user has the eventi enabled
	if not exists(
		select CustomerID
			from GoldenClub.tbl_Members 
		where CustomerID = @CustomerID 
		and GoldenParams & 32 = 32	 --eventi marketing enabled
		)
	begin
		set @msg = 'Customer is not invited to evento'
	end
	else
	begin
		declare @g datetime,
				@evID int

		set @g = getUTCDate()


		select 
			@evID = EventoID,
			@sms = SMSInvito
		from Marketing.tbl_Eventi
		where @g >= StartTimestampUTC and  @g <= StopTimestampUTC 
		--GoldenOnly = 0, GoldenAndDragon = 1, DragonOnly = 2
		AND 
		(
			([DragonAndGolden] = 0 AND @MemberTypeID = 1) or
			([DragonAndGolden] = 1 AND @MemberTypeID in (1,2) ) or
			([DragonAndGolden] = 2 AND @MemberTypeID = 2) 
		)		
		if @evID is not null AND @sms IS NOT null
		begin
			exec GeneralPurpose.usp_SendSMS
					@recp,
					@sms, 
					@msg output

			if @msg <> 'OK'
			begin
				raiserror('Cannot send sms: %s',16,1,@msg)
				return 1
			end	
		end
	end
			
end
return 0
GO
