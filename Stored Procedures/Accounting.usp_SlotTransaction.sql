SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_SlotTransaction]
@OpTypeID				INT,
@SlotNr					INT,
@IssueTimeStampLoc		DATETIME,
@AmountCents			INT,
@lfid					INT,
@jpID					INT, --only for jackpot
@pin					INT, --only for jackpot
@instance				INT, --only for jackpot
@InterventoID			INT, --only for shortpay
@transID				INT OUTPUT,
@TimeStampLoc			DATETIME OUTPUT
AS

IF @OpTypeID IS NULL OR @OpTypeID < 15 OR @OpTypeID > 17
begin
	raiserror('Invalid @OpTypeID (%d) specified ',16,1,@OpTypeID)
	RETURN 1
END

IF @InterventoID IS NULL 
BEGIN
	--we have to specify a lifecycle
	IF @lfid IS NULL OR @lfid <= 0 
	begin
		raiserror('Invalid @lfid specified ',16,1)
		RETURN 1
	END
END
ELSE
BEGIN
	--make sure it is a rimborso
	if not exists(select InterventoID from Techs.Rimborsi where InterventoID = @InterventoID)
	begin
		raiserror('Invalid interventoID (%d) specified ',16,1,@InterventoID)
		return 1
	END
	IF @transID IS NOT NULL
	begin
		raiserror('cannot specify both @lfid and @InterventoID ',16,1)
		return 1
	END
	--look for the transaction that migth exists
	select @transID = [SlotTransactionID] FROM [Accounting].[tbl_SlotTransactions] WHERE InterventoID = @InterventoID
END


IF @transID IS NULL OR not exists (select [SlotTransactionID] FROM [Accounting].[tbl_SlotTransactions] WHERE [SlotTransactionID] = @transID) 
begin
	--this is a manually inserted handpay
	--check all input parameters
	IF @SlotNr is null or @SlotNr <= 0
	begin
		raiserror('Invalid @SlotNr specified ',16,1)
		RETURN 1
	END
	IF @IssueTimeStampLoc is null 
	begin
		raiserror('Invalid @IssueTimeStampLoc specified ',16,1)
		RETURN 1
	END

	IF @AmountCents IS NULL OR @AmountCents = 0 OR ( @AmountCents <0 AND @OpTypeID <> 17)   
	BEGIN
		raiserror('Invalid @Amount specified ',16,1)
		RETURN 1
	END

	--check jackpot
	if @OpTypeID = 15 and NOT exists (
	SELECT [JackpotID]  FROM [CasinoLayout].[Jackpots]
	where [JackpotID] = @jpID
	)
	begin
		raiserror('Invalid JackpotID (%d) specified ',16,1,@jpID)
		RETURN 1
	END

END
ELSE
BEGIN

	--make sure we dont change the type
	IF not exists (select [SlotTransactionID] FROM [Accounting].[tbl_SlotTransactions] WHERE [SlotTransactionID] = @transID AND OpTypeID = @OpTypeID)
	BEGIN
		raiserror('Cannot change the OpTypeID',16,1)
		RETURN 1
	END

	IF @AmountCents IS NULL  --we did not specify an @AmountCents keep the existing one
		SELECT @AmountCents = AmountCents FROM [Accounting].[tbl_SlotTransactions] WHERE [SlotTransactionID] = @transID 

	IF @SlotNr is NULL --we di not specify an @SlotNr keep the existing one
		SELECT @SlotNr = SlotNr FROM [Accounting].[tbl_SlotTransactions] WHERE [SlotTransactionID] = @transID 

END

--shortpay and handpay carry no jackpot info
if @OpTypeID = 16 or @OpTypeID = 17
BEGIN
	set @jpID		= null
	set @pin		= null
	set @instance	= null
END

SET @TimeStampLoc = getutcdate()

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_SlotTransaction

BEGIN TRY  

	IF @transID IS NULL
	BEGIN

		--transaction does not exists insert it
		INSERT INTO [Accounting].[tbl_SlotTransactions]
			   ([SlotNr]
			   ,[OpTypeID]
			   ,[AmountCents]
			   ,[LifeCycleID]
			   ,[PaymentTimeUTC]
			   ,[JackpotID]
			   ,[PinCode]
			   ,JpInstance
			   ,InterventoID)
		 VALUES
			   (@SlotNr
			   ,@OpTypeID
			   ,@AmountCents
			   ,@lfid
			   ,@TimeStampLoc
				,@jpID	
				,@pin	
				,@instance
				,@InterventoID
			   )
	
		SET @transID = SCOPE_IDENTITY()

	END
	ELSE
	BEGIN

		UPDATE [Accounting].[tbl_SlotTransactions]
		   SET [LifeCycleID]		= @lfid
			  ,[PaymentTimeUTC]		= @TimeStampLoc
			  ,[AmountCents]		= @AmountCents
			  ,SlotNr				= @SlotNr
			  ,[CancelID]			= NULL
		WHERE [SlotTransactionID] = @transID

	END


	SET @TimeStampLoc = GeneralPurpose.fn_UTCToLocal(1,@TimeStampLoc)

	COMMIT TRANSACTION trn_SlotTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_SlotTransaction	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
GRANT EXECUTE ON  [Accounting].[usp_SlotTransaction] TO [TecRole]
GO
