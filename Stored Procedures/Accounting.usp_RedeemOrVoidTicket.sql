SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_RedeemOrVoidTicket]
 @TicketNumber			CHAR(18),
 @AmountCents			INT,
 @lfid					INT,
 @isSfr					bit,
 @isPromo				BIT,
 @isVoid				bit,
 @issueLocation			varchar(32),
 @issueTimeLoc			datetime,
 @TransID				INT OUTPUT,
 @TransTimeStampLoc		datetime output
AS


--only from cage CC
IF @lfid is null or not exists (select LifeCycleID from Accounting.vw_AllStockLifeCycles where LifeCycleID = @lfid and StockTypeID in (4,7))
begin
	raiserror('Invalid @@lfid (%d) specified or not a cage',16,1,@lfid)
	RETURN 1
END


--amount must be positive for redeemed tickets
IF @AmountCents IS NULL OR @AmountCents <= 0 
begin
	raiserror('Invalid @Amount specified (%d)',16,1,@AmountCents)
	RETURN 1
END


IF @TicketNumber IS NULL OR len(@TicketNumber) = 0 
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
END


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_RedeemOrVoidTicket

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
				   ,[IssueTimeUTC])

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
					   )




	set @TransTimeStampLoc = GeneralPurpose.fn_UTCToLocal(1,@TransTimeStampLoc)





COMMIT TRANSACTION trn_RedeemOrVoidTicket

END TRY  
BEGIN CATCH  
	DECLARE @err INT
	ROLLBACK TRANSACTION trn_RedeemOrVoidTicket		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove

END CATCH


return @ret

GO
