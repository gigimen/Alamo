SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Accounting].[usp_IssueDRGTTicket]
 @TicketNumber				BIGINT,
 @AmountCents				INT,
 @isTicketSfr				BIT,
 @isPromo					BIT,
 @lfid						INT,
 @siteid					INT,
 @TransTimeStampLoc			DATETIME OUTPUT,
 @transID					INT OUTPUT 
AS

--amount must be negative for issued tickets
IF @AmountCents IS NULL OR @AmountCents > 0 
begin
	raiserror('Invalid @Amount specified (%d)',16,1,@AmountCents)
	return 1
END

IF @TicketNumber IS NULL OR @TicketNumber <= 0 
begin
	raiserror('Invalid @TicketNumber specified ',16,1)
	return 1
END
declare @location VARCHAR(32)

SELECT @location = Tag FROM Accounting.vw_AllStockLifeCycles where LifeCycleID = @lfid

IF @location IS NULL 
begin
	raiserror('Invalid @lfid (%d) specified ',16,1,@lfid)
	return 1
END


IF @siteID IS NULL OR NOT EXISTS (SELECT siteid FROM CasinoLayout.Sites WHERE SiteID = @siteID)
begin
	raiserror('Invalid @siteID specified ',16,1)
	RETURN 1
END


SET @TransTimeStampLoc = getutcdate()


--first find or insert the ticket int the eurotracking table

--check that the ticket issue is not yet recorded
/*
declare @d int
SELECT @d = -AmountCents FROM [Accounting].[tbl_TicketTransactions] WHERE TicketNumber = @TicketNumber and AmountCents < 0 --issued
IF @d is not null
BEGIN
	raiserror('Ticket already issued at one cage with %d cents',16,1,@d)
	RETURN 1
END
*/
declare @ret int
set @ret = 0
BEGIN TRANSACTION trn_IssueDRGTTicket

BEGIN TRY  

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
			   ,FK_SiteID)

	 VALUES
				   (
				   @TicketNumber
				   ,@lfid
				   ,@AmountCents
				   ,@TransTimeStampLoc
				   ,0
				   ,@isPromo
				   ,@isTicketSfr
				   ,@location
				   ,@TransTimeStampLoc
				   ,@siteid)
	SET @transID = SCOPE_IDENTITY()
	SET @TransTimeStampLoc = GeneralPurpose.fn_UTCToLocal(1,@TransTimeStampLoc)



	COMMIT TRANSACTION trn_IssueDRGTTicket

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_IssueDRGTTicket		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
RETURN @ret

GO
