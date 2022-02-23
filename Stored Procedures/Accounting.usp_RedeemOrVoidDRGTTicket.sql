SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_RedeemOrVoidDRGTTicket]
 @TicketNumber			BIGINT,
 @AmountCents			INT,
 @lfid					INT,
 @isSfr					BIT,
 @isPromo				BIT,
 @isVoid				BIT,
 @isDRGT				BIT,
 @issueLocation			VARCHAR(32),
 @issueTimeLoc			DATETIME,
 @SiteID				INT,
 @TransID				INT OUTPUT,
 @TransTimeStampLoc		DATETIME OUTPUT
AS

----

--only from cage CC
IF @lfid is null or not exists (select LifeCycleID from Accounting.vw_AllStockLifeCycles where LifeCycleID = @lfid and StockTypeID in (4,7,5))
BEGIN
	--only cages or incasso can void or redeem tickets
	raiserror('Invalid @@lfid (%d) specified or not a cage or incasso',16,1,@lfid)
	RETURN 1
END

DECLARE @StockID INT
SELECT @StockID = StockID FROM Accounting.tbl_LifeCycles where LifeCycleID = @lfid

--amount must be positive for redeemed tickets
IF @AmountCents IS NULL OR @AmountCents <= 0 
begin
	raiserror('Invalid @Amount specified (%d)',16,1,@AmountCents)
	RETURN 1
END


IF @SiteID IS NULL OR NOT EXISTS (SELECT SiteID FROM CasinoLayout.Sites WHERE SiteID = @SiteID)
begin
	raiserror('Invalid @SiteID specified ',16,1)
	RETURN 1
END

IF @TicketNumber IS NULL OR @TicketNumber <= 0 
begin
	raiserror('Invalid @@TicketNumber specified ',16,1)
	RETURN 1
END

IF @isSfr IS NULL 
begin
	raiserror('Invalid @isSfr specified ',16,1)
	RETURN 1
END

IF @isPromo = 1 AND @isVoid = 0
begin
	raiserror('Cannot redeem a promo ticket',16,1)
	RETURN 1
END


SET @TransTimeStampLoc= getutcdate()

--first check the ticket is not yet redeemed
IF EXISTS (
SELECT [TicketNumber]
  FROM [Accounting].[tbl_TicketTransactions]
WHERE TicketNumber = @TicketNumber AND ([AmountCents] > 0 or IsVoided = 1) --either  redeemed or voided
)
BEGIN
	raiserror('Ticket already redeemed or voided at cage',16,1)
	RETURN 2
END


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_RedeemOrVoidDRGTTicket

BEGIN TRY  
	--if it is a void update the exisiting ticket transactions
	IF @isVoid = 1 AND EXISTS (
	SELECT [TicketNumber]
	  FROM [Accounting].[tbl_TicketTransactions]
	WHERE TicketNumber = @TicketNumber 
	)
	BEGIN
		UPDATE [Accounting].[tbl_TicketTransactions]
		SET IsVoided = @isVoid
		WHERE TicketNumber = @TicketNumber
    END

	--insert ticket redemption or void
	INSERT INTO [Accounting].[tbl_TicketTransactions]
				   ([TicketNumber]
				   ,[LifeCycleID]
				   ,[AmountCents]
				   ,[TransTimeUTC]
				   ,[IsVoided]
				   ,[IsPromo]
				   ,[IsSfr]
				   ,[IssueLocation]
				   ,[IssueTimeUTC]
				   ,[IsDRGT]
				   ,FK_SiteID)

	 VALUES
					   (
					   @TicketNumber
					   ,@lfid
					   ,@AmountCents
					   ,@TransTimeStampLoc
					   ,@isVoid
					   ,@isPromo
					   ,@isSfr
					   ,@issueLocation
					   ,GeneralPurpose.fn_UTCToLocal(0,@issueTimeLoc) --transform into UTC
					   , @isDRGT
					   ,@SiteID)

	

	SET @TransID = SCOPE_IDENTITY()
	SET @TransTimeStampLoc = GeneralPurpose.fn_UTCToLocal(1,@TransTimeStampLoc)


	IF @isDRGT = 0 --not a drgt ticket: go in old stuff to mark it as redeemed
	BEGIN

		--in case it was from the old Galaxis system
		--mark it has been redeemed
	
		IF EXISTS (SELECT TicketNumber FROM [OldStuff].[tickets].[tbl_LiableTickets] WHERE TicketNumber = @TicketNumber)
		BEGIN
			UPDATE [OldStuff].[tickets].[tbl_LiableTickets]
			SET RedeemStockID = @StockID,RedeemTimestampLocal = @TransTimeStampLoc
			WHERE TicketNumber = @TicketNumber
		END	
	
	END

COMMIT TRANSACTION trn_RedeemOrVoidDRGTTicket

END TRY  
BEGIN CATCH  
	DECLARE @err INT
	ROLLBACK TRANSACTION trn_RedeemOrVoidDRGTTicket		
	DECLARE @dove AS VARCHAR(50)
	SET @ret = ERROR_NUMBER()
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove

END CATCH


RETURN @ret
GO
