SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Snoopy].[usp_Assegni_IncassoAssegno]
@CustID						INT,
@euroCents					INT ,
@ExchangeRate				FLOAT,	
@Commissione				FLOAT ,
@CreditiGiocoRate			FLOAT,
@SourceLifeCycleID			INT,
@UserAccessID				INT,
@BankAccountID				INT OUTPUT,
@BankAccountNr				VARCHAR(64),
@BankName					VARCHAR(256),
@IDDocID					INT,
@ContropartitaID			INT,
@CentaxCode					VARCHAR(64),
@NrAssegno					VARCHAR(64),
@CustTransID				INT OUTPUT,
@CustTransTimeLoc			DATETIME OUTPUT,
@CustTransTimeUTC			DATETIME OUTPUT,
@AssegnoID					INT OUTPUT
AS
--first some check on parameters
if not exists(select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID)
begin
	raiserror('Invalid CustomerID (%d) specified ',16,1,@CustID)
	RETURN 1
END
if @euroCents is null or @euroCents = 0
begin
	raiserror('Invalid @euroCents specified',16,1)
	RETURN 1
END
if @ExchangeRate is null or @ExchangeRate = 0
begin
	raiserror('Invalid @@ExchangeRate specified',16,1)
	RETURN 1
END

--make sure we provide a valid contropartita
IF NOT EXISTS (
	SELECT ContropartitaID 
	FROM CasinoLayout.tbl_Contropartite 
	WHERE ContropartitaID = @ContropartitaID 
	)  
begin
	raiserror('Invalid @ContropartitaID specified',16,1)
	return 1
END


if not exists (select IDDocumentID from Snoopy.tbl_IDDocuments 
where IDDocumentID = @IDDocID 
and CustomerID = @CustID --must refer to the same customer of the banck account
)
begin
	raiserror('Invalid IDDocumentID (%d) specified or Document refers to a different customer',16,1,@IDDocID)
	RETURN 1
END
declare @GamingDate datetime
declare @Tag varchar(64)

if @AssegnoID is null 
begin
	if not exists (
	select LifeCycleID from Accounting.tbl_LifeCycles 
	inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
	where LifeCycleID = @SourceLifeCycleID 
	and CasinoLayout.Stocks.StockTypeID in(4,7) -- cassa and main cassa only
	)
	begin
		raiserror('Invalid SourceLifeCycleID (%d) specified ',16,1,@SourceLifeCycleID)
		RETURN 1
	END
	--get gaming date and Tag from LifeCles table
	SELECT 
		@GamingDate = Accounting.tbl_LifeCycles.GamingDate,
		@Tag = CasinoLayout.Stocks.Tag
	FROM Accounting.tbl_LifeCycles 
	INNER JOIN CasinoLayout.Stocks ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
	WHERE LifeCycleID = @SourceLifeCycleID 
END
ELSE
BEGIN
	--get gaming date and Tag from LifeCles table
	SELECT 
		@GamingDate			= GamingDate,
		@Tag				= Tag
	FROM Snoopy.vw_AllAssegniEx
	WHERE  AssegnoID = @AssegnoID
END


if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	RETURN 1
END

--if @CentaxCode is null or len(@CentaxCode) = 0
--begin
--	raiserror('Invalid CentaxCode specified',16,1)
--	return 1
--end

if @NrAssegno is null or len(@NrAssegno) = 0
begin
	raiserror('Invalid Numero Assegno specified',16,1)
	RETURN 1
END

if @BankAccountNr is null or len(@BankAccountNr) = 0
begin
	raiserror('Invalid BankAccountNr specified',16,1)
	RETURN 1
END

if @BankName is null or len(@BankName) = 0
begin
	raiserror('Invalid Bank Name specified',16,1)
	RETURN 1
END

--if a banck account id has not been provided check if bank account exists
--for that customer
if @BankAccountID is null 
	select @BankAccountID = BankAccountID
	from Snoopy.tbl_CustomerBankAccounts 
	Where CustomerID = @CustID  
	and BankName = @BankName
	and AccountNr = @BankAccountNr

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_IncassoAssegnoEx

BEGIN TRY  



if @BankAccountID is null
begin
	--insert a new back account information
	insert into Snoopy.tbl_CustomerBankAccounts 
	(
	CustomerID,
	BankName,
	AccountNr
	)
	values
	(
	@CustID,
	@BankName,
	@BankAccountNr
	)
	SET @BankAccountID = SCOPE_IDENTITY()
END
ELSE
BEGIN
	UPDATE Snoopy.tbl_CustomerBankAccounts
	SET  BankName=@BankName,
	AccountNr=@BankAccountNr
	WHERE CustomerID = @CustID AND BankAccountID = @BankAccountID
END

IF @AssegnoID IS NULL -- we have to create a new assegno transaction
begin
	set @CustTransTimeUTC = GetUTCDate()
	--create a new customertransaction
	insert into Snoopy.tbl_CustomerTransactions
	(
		OpTypeID,
		CustomerTransactionTime,
		SourceLifeCycleID,
		CustomerID,
		UserAccessID
	)
	values(
		9, --Assegno,
		@CustTransTimeUTC,
		@SourceLifeCycleID,
		@CustID,
		@UserAccessID)
	set @CustTransID = SCOPE_IDENTITY()
	
	--store assegno importo
	insert into Snoopy.tbl_CustomerTransactionValues
	(
		DenoID,
		CustomerTransactionID,
		Quantity,
		ExchangeRate,
		CashInbound
	)
	values(
		173, --euro cents for assegni
		@CustTransID,
		@euroCents,
		--13.12.2019 non imagazzinare piu il cambio!!
		1.0,--@ExchangeRate,
		0	--emission assegno is outboud
		)


	--now insert into Assegni the brand new created customer transaction
	INSERT INTO [Snoopy].[tbl_Assegni]
           ([FK_BankAccountID]
           ,[FK_IDDocumentID]
           ,[FK_EmissCustTransID]
           ,[FK_ContropartitaID]
           ,[NrAssegno]
           ,[CentaxCode]
           ,[Commissione]
           ,[CreditiGiocoRate])
	values
	(
		@BankAccountID,
		@IDDocID,
		@CustTransID,
		@ContropartitaID,
		RTRIM(@NrAssegno),
		RTRIM(@CentaxCode),
		@Commissione,
		@CreditiGiocoRate
	)
	SET @AssegnoID = SCOPE_IDENTITY()

END
ELSE
BEGIN
	DECLARE @OldQuantity INT--,@OldExrate FLOAT

	--we specified and assegno than we want to change the emission transaction
	--go get it
	select	@CustTransID		= a.FK_EmissCustTransID,
			@CustTransTimeUTC	= t.CustomerTransactionTime,
			@OldQuantity		= v.Quantity--,
			--@OldExrate			= v.ExchangeRate
	from [Snoopy].[tbl_Assegni] a
	INNER JOIN Snoopy.tbl_CustomerTransactions t ON a.FK_EmissCustTransID = t.CustomerTransactionID 
	INNER JOIN Snoopy.tbl_CustomerTransactionValues v ON a.FK_EmissCustTransID = v.CustomerTransactionID 
	AND v.DenoID = 173 --euro cents for assegni
	where a.PK_AssegnoID = @AssegnoID

	--update assegno information
	UPDATE [Snoopy].[tbl_Assegni]
	   SET [FK_BankAccountID]		= @BankAccountID
		  ,[FK_IDDocumentID]		= @IDDocID
		  ,[FK_ContropartitaID]		= @ContropartitaID
		  ,[NrAssegno]				= RTRIM(@NrAssegno)
		  ,[CentaxCode]				= RTRIM(@CentaxCode)
		  ,[Commissione]			= @Commissione
		  ,[CreditiGiocoRate]		= @CreditiGiocoRate
	WHERE PK_AssegnoID				= @AssegnoID

/*DO NOT CHANGE TRANSACTION INFO ANYMORE
	update Snoopy.CustomerTransactions
	set CustomerTransactionTime = @CustTransTimeUTC,
		UserAccessID = @UserAccessID
	where CustomerTransactionID = @CustTransID
	SELECT @err = @@ERROR IF (@ERR <> 0) BEGIN ROLLBACK TRANSACTION InsertASSEGNO return @ERR END
*/
	--update assegno amount
	UPDATE Snoopy.tbl_CustomerTransactionValues
		SET Quantity	= @euroCents--,
			--ExchangeRate= @ExchangeRate
	WHERE CustomerTransactionID = @CustTransID
	AND DenoID = 173 --euro cents for assegni


	--insert a new entry in [FloorActivity].[CustomerTransactionModifications] to record the change of value
	INSERT INTO FloorActivity.tbl_CustomerTransactionModifications
			(UserAccessID
			,[CustomerTransactionID]
			,[DenoID]
			,CashInbound
			,[FromQuantity]
			,[ToQuantity]
			,[ExchangeRate])
	VALUES
			(
			@UserAccessID,
			@CustTransID,
			173, --euro cents for assegni
			0,	--emission assegno is outboud
			@OldQuantity,
			@euroCents,
			1.0--@OldExrate
			)
END



		
	COMMIT TRANSACTION trn_IncassoAssegnoEx

	-- return cust transaction time in local hour
	SET @CustTransTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@CustTransTimeUTC)


END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_IncassoAssegnoEx
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
