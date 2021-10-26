SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE       PROCEDURE [GoldenClub].[usp_ReassignCard]
@oldCardID 		int,
@tempCardID		int,
@UserAccessID	int,
@TimeStampLoc	datetime output,
@newCardID 		int output
AS

 
declare 
	@logName varchar(64),
	@oldcardTypeid INT,
	@CustID INT,
	@TimeStampUTC DATETIME,
	@memberTypeID int,
	@cancID int

select @logName = loginName from FloorActivity.vw_AllUserAccesses where UserAccessID = @UserAccessID

if @logName is null
begin
	raiserror('Invalid user access(%d) specified',16,1,@UserAccessID)
	return (1)
END

select @oldcardTypeid=CardTypeID from GoldenClub.tbl_Cards where GoldenClubCardID = @oldCardID
if @oldCardID is null or @oldcardTypeid is NULL
begin
	raiserror('Invalid GoldenClubCardID (%d) specified',16,1,@oldCardID)
	return (2)
end

--old card must be assigned to a customer
select @CustID = CustomerID,@memberTypeID=MemberTypeID from GoldenClub.tbl_Members where GoldenClubCardID = @oldCardID
if @CustID is null
begin
	raiserror('Invalid GoldenClubCardID (%d). Card is not linked to a customer',16,1,@oldCardID)
	return (1)
END

if @tempCardID is null  
begin
	raiserror('Null new GoldenClubCardID specified',16,1)
	return (2)
END

/*LM 1.5.2018: WE ASSIGN ONLY admiral card
if @memberTypeID IN(1,2) --golden and dragon members we can reassign ony temparay cards
AND not exists (select GoldenClubCardID from GoldenClub.Cards where GoldenClubCardID = @tempCardID and CardTypeID = 2)
begin
	raiserror('Invalid temporary GoldenClubCardID (%d) specified',16,1,@tempCardID)
	return (2)
END

if @memberTypeID = 3 --admiral members we can reassign ony admiral cards
AND not exists (select GoldenClubCardID from GoldenClub.Cards where GoldenClubCardID = @tempCardID and CardTypeID = 4)
begin
	raiserror('Invalid Admiral CardID (%d) specified',16,1,@tempCardID)
	return (2)
END
*/
--SE LA CARTA NON È admiral RAISERROR
IF not exists (select GoldenClubCardID from GoldenClub.tbl_Cards where GoldenClubCardID = @tempCardID and CardTypeID = 4)
begin
	raiserror('Invalid Admiral CardID (%d) specified: Assegnare una nuova carta Admiral!!',16,1,@tempCardID)
	return (2)
END


set @TimeStampUTC = getutcdate()

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_ReassignCard

BEGIN TRY  



	--we have to cancel the old card from the database
	-- it has been lost, stolen or demagnetic
	--first create a new CancelAction
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
	VALUES(@TimeStampUTC,@UserAccessID)


	set @cancID = SCOPE_IDENTITY()

	--mark old card as cancelled
	update GoldenClub.tbl_Cards
		set CancelID= @cancID
	where GoldenClubCardID = @oldCardID


	--link the new card to the customer in GoldenClub table
	update GoldenClub.tbl_Members
		set GoldenClubCardID = @tempCardID,
		LinkTimeStampUTC = @TimeStampUTC
	where CustomerID = @CustID



	--update information on customer card history
	IF EXISTS (SELECT CustomerID FROM GoldenClub.tbl_CustomerCardsHistory WHERE CustomerID = @CustID AND ToUTC IS null AND [GoldenClubCardID] = @oldCardID)
	BEGIN
		UPDATE  GoldenClub.tbl_CustomerCardsHistory 
		SET ToUTC = @TimeStampUTC
		WHERE CustomerID = @CustID AND ToUTC IS NULL
	end  
	ELSE IF @oldCardID IS NOT NULL --this card ownership was no recorded: record it now
	BEGIN
		INSERT INTO GoldenClub.tbl_CustomerCardsHistory
				   ([GoldenClubCardID]
				   ,[CustomerID]
				   ,[FromUTC]
				   ,[ToUTC])
		VALUES
		(
			@oldCardID,
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
		@tempCardID,
		@CustID,
		@TimeStampUTC,
		 null
	)

	/*ln 1.5.2018: non creimao piu la carta personale
	if @memberTypeID IN(1,2) --golden and dragon members 
	--for golden and dragon we have to create a new personal Card and put it into 'da produrre state'
	begin
		execute @err = GoldenClub.usp_CreateGoldenCard
			@CustID 	,
			@newCardID 	output
	END
	ELSE

		--this is going to be his new card
		SET @newCardID = @tempCardID
	*/
		SET @newCardID = @tempCardID



	--return the @TimeStampLoc in local hour
	set @TimeStampLoc = GeneralPurpose.fn_UTCToLocal(1,@TimeStampUTC)

	declare @attribs varchar(4096)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) +
		''' User=''' + @logName +
		''' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) +			
		''' GCCardID=''' + CAST(@tempCardID as varchar(32)) + ''''
 
	execute [GeneralPurpose].[usp_BroadcastMessage] 'GCCardReassigned',@attribs
	/*
	<MESS type='GCCardReassigned' CustID='253' CardID='777'/>
	*/

	COMMIT TRANSACTION trn_ReassignCard

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ReassignCard
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
