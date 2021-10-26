SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE     PROCEDURE [GoldenClub].[usp_AssociaCard]
@CustID 			int,
@GoldenClubCardID 	int,
@IdDocID			int,
@SMSNumber			varchar(50),
@EMailAddress		varchar(50),
@GoldenParams		int output,
@UserAccessID		int,
@TimeStampLoc	 	datetime output,
@PersonalClubCardID int output
AS


/*

CardTypeID	FDescription	IsPersonal	
1			Golden			1			
2			Temporary		0			
3			Dragon			1			
4			Admiral			1			
5			Mobile App		1			
*/
--check input values
DECLARE 
	@cardTypeid INT,
	@IsPersonal BIT,
	@MemberTypeID INT,
	@expdate DATETIME,
	@TimeStampUTC datetime, 
	@DocInfo varchar(64),
	@currCardID INT,
	@anotherCardID INT,
	@logName varchar(64)


select @logName = loginName 
from FloorActivity.vw_AllUserAccesses 
where UserAccessID = @UserAccessID

if @logName is null
begin
	raiserror('Invalid user access(%d) specified',16,1,@UserAccessID)
	return (1)
END

if @CustID is null or not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer is not part of GoldenClub',16,1,@CustID)
	return (2)
end

IF @GoldenClubCardID > 0
begin 
	select 
		@cardTypeid = c.CardTypeID
		,@IsPersonal = 1--ct.IsPersonal  now always personal
	from GoldenClub.tbl_Cards c
	--INNER JOIN GoldenClub.CardTypes ct ON c.CardTypeID = ct.CardTypeID
	where c.GoldenClubCardID = @GoldenClubCardID


	if @cardTypeid is NULL
	begin
		raiserror('Invalid GoldenClubCardID (%d) specified',16,1,@GoldenClubCardID)
		return (3)
	END
END
ELSE
begin
	--we have to give an new cardid
	SELECT @GoldenClubCardID = MIN(GoldenClubCardID)
	from GoldenClub.tbl_Cards c
	where GoldenClubCardID >= 200000 AND GoldenClubCardID < 500000

	IF @GoldenClubCardID IS NULL
		SET @GoldenClubCardID = 200000

	SET @GoldenClubCardID = @GoldenClubCardID + 1

	INSERT INTO GoldenClub.tbl_Cards
           ([GoldenClubCardID]
           ,[CardStatusID]
           ,[CustomerID]
           ,[InsertTimeStampUTC]
           ,[CancelID]
           ,[CardTypeID])
     VALUES
           (@GoldenClubCardID
           ,3 --consegnata
           ,@CustID
           ,GETUTCDATE()
           ,NULL
           ,5 --from mobile
		   )




END



SELECT 
	@currCardID = GoldenClubCardID ,
	@MemberTypeID = MemberTypeID
from GoldenClub.tbl_Members 
where CustomerID = @CustID


select @anotherCardID = GoldenClubCardID 
from GoldenClub.vw_AllGoldenCards
where CustomerID = @CustID 
	and @IsPersonal = 1  --not a temporary card
	and GoldenClubCardID <> @GoldenClubCardID
	and IsPersonal = 1 --IT IS HIS personal card
	and CancelID is null


/*lm 1.5.2018: assegnamo carte admiral a tutti

--check if the customer has already another personal card non cancelled
if @anotherCardID IS NOT null 
begin
	raiserror('Cannot assign card %d to customer %d: already got card %d!',16,1,@GoldenClubCardID,@CustID,@anotherCardID)
	return (4)
end

--PRINT @cardTypeid
IF @cardTypeid = 4 --admiral cards can only be assigned to Admiral members
AND @MemberTypeID <> 3
BEGIN
	raiserror('CardID (%d) is ADMIRAL CARD and cannot be assigned to non admiral members!!',16,1,@GoldenClubCardID)
	return (3)
END
*/

--if we specify to enable sms but did not specify a number
if @GoldenParams & 1 = 0
--if @smsDisabled = 0 
and (@SMSNumber is null or len(@SMSNumber) = 0)
begin
	raiserror('Invalid SMSNumber specified',16,1)
	return (5)
end

if @GoldenParams & 1 = 1 --if we disable sms number
	set @SMSNumber = null
	
if @IdDocID is null or not exists 
(
	select IDDocumentID from Snoopy.vw_AllCustomerIDDocuments 
	where IDDocumentID = @IdDocID and DocExpired is null
)
begin
	raiserror('Invalid IDDocumentID (%d) specified or document is expired',16,1,@IdDocID)
	return (6)
end

select @expdate = d.ExpirationDate,
	@DocInfo = dt.FDescription + ' ' + d.DocNumber
from Snoopy.tbl_IDDocuments d
inner join Snoopy.tbl_IDDocTypes dt on dt.IDDocTypeID = d.IDDocTypeID
where d.IDDocumentID = @IdDocID

set @TimeStampUTC = getutcdate()

--check if sms has been enabled
--if already checked but number has changed flag it to non checked
if @GoldenParams & 1 = 0 and exists 
(
	select CustomerID from  GoldenClub.tbl_Members 
	where CustomerID = @CustID 
	and SMSNumber <> @SMSNumber 
	and GoldenParams & 1 = 1 --SMSNumber disabled
	and GoldenParams & 2 = 2 --SMSNumberChecked = 1
)
begin
	--reset flag to not checked
	set @GoldenParams = @GoldenParams ^ 2
END

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_AssociaCard

BEGIN TRY  


	/*record new card linked to customer*/
	--mark his first membership to the club if not yet done
	if exists (select CustomerID from  GoldenClub.tbl_Members where CustomerID = @CustID and MembershipTimeStampUTC is null)
		update GoldenClub.tbl_Members
			set 
			SMSNumber 				= @SMSNumber,
			EMailAddress 			= @EMailAddress,
			GoldenClubCardID		= @GoldenClubCardID,
			IDDocumentID 			= @IdDocID,
			LinkTimeStampUTC		= @TimeStampUTC,
			LinkUserAccessID		= @UserAccessID,
			GoldenParams			= @GoldenParams,
			MembershipTimeStampUTC	= @TimeStampUTC
		where CustomerID			= @CustID
	else
		update GoldenClub.tbl_Members
			set 
			SMSNumber 				= @SMSNumber,
			EMailAddress 			= @EMailAddress,
			GoldenClubCardID		= @GoldenClubCardID,
			IDDocumentID 			= @IdDocID,
			LinkTimeStampUTC		= @TimeStampUTC,
			LinkUserAccessID		= @UserAccessID,
			GoldenParams			= @GoldenParams
		where CustomerID			= @CustID

	--update information on customer card history if it is a different card
	IF @currCardID IS NULL OR @currCardID <> @GoldenClubCardID
	begin

		IF EXISTS (SELECT CustomerID FROM GoldenClub.tbl_CustomerCardsHistory WHERE CustomerID = @CustID AND ToUTC IS null AND [GoldenClubCardID] = @currCardID)
		BEGIN
			UPDATE  GoldenClub.tbl_CustomerCardsHistory 
			SET ToUTC = @TimeStampUTC
			WHERE CustomerID = @CustID AND ToUTC IS NULL
		end  
		ELSE IF @currCardID IS NOT NULL --this card ownership was no recorded: record it now
		BEGIN
			INSERT INTO GoldenClub.tbl_CustomerCardsHistory
					   ([GoldenClubCardID]
					   ,[CustomerID]
					   ,[FromUTC]
					   ,[ToUTC])
			VALUES
			(
				@currCardID,
				@CustID,
				@TimeStampUTC,
				@TimeStampUTC
			)	
		end

		--insert new linked card in card history table
		INSERT INTO GoldenClub.tbl_CustomerCardsHistory
				   ([GoldenClubCardID]
				   ,[CustomerID]
				   ,[FromUTC]
				   ,[ToUTC])
		VALUES
		(
			@GoldenClubCardID,
			@CustID,
			@TimeStampUTC,
			 null
		)
	END

	/*lm 1.5.2018: assign admiral card always
	--if card is HIS PERSONAL set its status to 3 = consegnata
	if @IsPersonal = 1 --golden and dragon cards
	begin
		set @PersonalClubCardID = @GoldenClubCardID
		update GoldenClub.Cards
			set CardStatusID = 3
		where GoldenClubCardID = @GoldenClubCardID
	end
	else
	BEGIN
		IF  @cardTypeid = 2 --temporary cards
		begin
		--we are assigning a temporary card
		--the customer accepted to be part of the GoldenClub
		--create it's own personal card if not done yet
			select @PersonalClubCardID = GoldenClubCardID 
			from GoldenClub.Cards c
			INNER JOIN GoldenClub.CardTypes ct ON ct.CardTypeID = c.CardTypeID
			where CustomerID = @CustID AND c.CancelID IS NULL AND ct.IsPersonal = 1
        
			if @PersonalClubCardID is null
			begin

				execute	GoldenClub.usp_CreateGoldenCard
					@CustID 		,
					@PersonalClubCardID 	output
			END
		end    
		ELSE
			--admiral card is also the personal card  
			set @PersonalClubCardID = @GoldenClubCardID	  
	end
	*/

	set @PersonalClubCardID = @GoldenClubCardID
	update GoldenClub.tbl_Cards
		set CardStatusID = 3
	where GoldenClubCardID = @GoldenClubCardID



	--return the @TimeStampLoc in local hour
	set @TimeStampLoc = GeneralPurpose.fn_UTCToLocal(1,@TimeStampUTC)

	declare @attribs varchar(1024)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) +
		''' GCCardID=''' + CAST(@GoldenClubCardID as varchar(32)) +
		''' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) +			
		''' User=''' + @logName +
		''' SMS=''' + ISNULL(@SMSNumber,'') +
		''' GCParams=''' + CAST(@GoldenParams as varchar(32)) +
		''' GCMType=''' + CAST(@MemberTypeID as varchar(32)) +
		''' EMail=''' + ISNULL(@EMailAddress,'') +
		''' DocInfo=''' + @DocInfo +
		''' ExpirDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@expdate) +			
		''' GCDocID=''' +   CAST(@IdDocID as varchar(32)) + ''''
 
	/* 
	print	'CustID=''' + CAST(@custid as varchar(32)) 
	print	''' GCCardID=''' + CAST(@GoldenClubCardID as varchar(32)) 
	print	''' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) 	
	print	''' PersonalCardID=''' + CAST(@PersonalClubCardID as varchar(32)) 
	print	''' User=''' + @logName 
	print	''' SMS=''' + ISNULL(@SMSNumber,'') 
	print	''' GCParams=''' + CAST(@GoldenParams as varchar(32)) 
	print	''' GCMType=''' + CAST(@MemberTypeID as varchar(32)) 
	print	''' EMail=''' + ISNULL(@EMailAddress,'') 
	print	''' DocInfo=''' + @DocInfo 
	print	''' ExpirDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@expdate) 
	print	''' GCDocID=''' +   CAST(@IdDocID as varchar(32)) 
	*/
 

	execute [GeneralPurpose].[usp_BroadcastMessage] 'AssociaCard',@attribs
	/*
	<ALAMO version='1'><MESS type='AssociaCard' CustID='766' GCCardID='700' TimeStampLoc='40093.4' PersonalCardID='700' User='GoldenClub' SMS='+393000000000' EMail='' GCDocID='13625'/></ALAMO>
	*/

	COMMIT TRANSACTION trn_AssociaCard

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_AssociaCard
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
