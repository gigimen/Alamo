SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [Accounting].[usp_SlotTransactionEx]
		@optypeid				INT,
		@ipAddr					INT,
		@IssueTimeStampLoc		DATETIME,
		@AmountCents			INT,
		@Currency				INT,
		@ExchangeRate			FLOAT,
		@lfid					INT,
		@ValidationNumber		BIGINT,
		@jpID					VARCHAR(4), --only for jackpot
		@jpName					VARCHAR(50), --only for jackpot
		@instance				INT, --only for jackpot
		@interventoID			INT, --only for shortpay
		@nota					VARCHAR(1024),
		@SlotTransID			INT OUTPUT,
		@timestampLoc			DATETIME OUTPUT
AS

IF @optypeid IS NULL OR @optypeid < 15 OR @optypeid > 17
begin
	raiserror('Invalid @optypeid (%d) specified ',16,1,@optypeid)
	RETURN 1
END

IF @interventoID IS NULL 
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
	if not exists(select InterventoID from Techs.Rimborsi where InterventoID = @interventoID)
	begin
		raiserror('Invalid interventoID (%d) specified ',16,1,@interventoID)
		return 1
	END
END



IF @ipAddr is null or @ipAddr <= 0
begin
	raiserror('Invalid @slotNr specified ',16,1)
	RETURN 1
END
IF @IssueTimeStampLoc is null 
begin
	raiserror('Invalid @IssueTimeStampLoc specified ',16,1)
	RETURN 1
END

IF @AmountCents IS NULL OR @AmountCents = 0 OR ( @AmountCents <0 AND @optypeid <> 17)   
BEGIN
	raiserror('Invalid @Amount specified ',16,1)
	RETURN 1
END

IF @Currency IS NULL OR @Currency NOT IN (0,4)   
BEGIN
	raiserror('Invalid @@Currency(%d) specified ',16,1,@Currency)
	RETURN 1
END

IF @Currency = 4 --swiss francs
BEGIN
    
	IF @ExchangeRate <> 1.0
	BEGIN
		raiserror('Invalid ExchangeRate specified for CHF',16,1)
		RETURN 1
	END
END
ELSE
BEGIN
	IF @ExchangeRate IS NULL OR @ExchangeRate <= 0
	BEGIN
		raiserror('Invalid ExchangeRate specified for EUR',16,1)
		RETURN 1
	END
END

--check jackpot
if @optypeid = 15 
BEGIN
	IF @jpName IS NULL OR LEN(@jpname) = 0 OR @jpID IS NULL OR LEN(@jpID) = 0
	begin
		raiserror('Invalid JpID or JpName specified ',16,1)
		RETURN 1
	END

	IF @instance IS NULL 
	BEGIN
		raiserror('Invalid @instance specified ',16,1)
		RETURN 1
	END

END

declare @ret INT,@tag VARCHAR(32),@gamingdate DATETIME
SET @ret = 0

SELECT @tag = Tag,@gamingdate = GamingDate FROM Accounting.vw_AllStockLifeCycles WHERE LifeCycleID = @lfid
IF @tag IS NULL
begin
	raiserror('Invalid @lfid specified ',16,1)
	RETURN 1
END

--shortpay and handpay carry no jackpot info
if @optypeid = 16 or @optypeid = 17
BEGIN
	set @jpID		= null
	set @instance	= null
END

SET @timestampLoc = getutcdate()

BEGIN TRANSACTION trn_SlotTransaction

BEGIN TRY  


		--transaction does not exists insert it
		INSERT INTO [Accounting].[tbl_SlotTransactions]
			   ([SlotNr]
			   ,[InsertTimeStampUTC]
			   ,[OpTypeID]
			   ,[AmountCents]
			   ,[ExchangeRate]
			   ,[Currency]
			   ,[LifeCycleID]
			   ,[PaymentTimeUTC]
			   ,[JpID]
			   ,[JpName]
			   ,JpInstance
			   ,InterventoID
			   ,[ValidationNumber]
			   ,Nota)
		 VALUES
			   (@ipAddr
			   --insert UTC issue time
			   ,GeneralPurpose.fn_UTCToLocal(0,@IssueTimeStampLoc)
			   ,@optypeid
			   ,@AmountCents
			   ,@ExchangeRate
			   ,@Currency
			   ,@lfid
			   ,@timestampLoc
				,@jpID	
				,@jpName
				,@instance
				,@interventoID
				,@ValidationNumber
				,@nota
			   )
	
	SET @SlotTransID = SCOPE_IDENTITY()

	COMMIT TRANSACTION trn_SlotTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_SlotTransaction	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH


--check to broadcast ig payment
DECLARE @AmountCentsCHF INT
SET @AmountCentsCHF = @AmountCents	* @ExchangeRate
IF 	@AmountCentsCHF	>= 2500000
BEGIN
	--big payment to be notified
	--broadcast alarm to sorveglinaza
	declare @attribs varchar(4096)
	set @attribs = 
		'IpAddr=''' + CAST(@ipAddr as varchar(32)) + '''' +
		' Currency=''' + CAST(@Currency as varchar(32)) + '''' +
		' AmountCents=''' + CAST(@AmountCents as varchar(32)) + '''' +
		' ValidationNumber=''' + + CAST(@ValidationNumber as varchar(32)) + '''' +
		' TimeStampUTC=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@timestampLoc) + '''' +
		' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@gamingdate) + '''' +
		' Tag=''' + @tag + '''' 
 
	execute [GeneralPurpose].[usp_BroadcastMessage] 'BigSlotPayment',@attribs

END

SET @timestampLoc = GeneralPurpose.fn_UTCToLocal(1,@timestampLoc)

RETURN @ret


GO
