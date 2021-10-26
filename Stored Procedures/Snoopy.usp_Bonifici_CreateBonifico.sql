SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Snoopy].[usp_Bonifici_CreateBonifico]
@CustID				INT,
@AmountCents		INT,
@CurrencyID			INT,
@SourceLifeCycleID	INT,
@UserAccessID		INT,
@BankAccountID		INT OUTPUT,
@BankAccountNr		VARCHAR(64),
@BankName			VARCHAR(256),
@BankAddress		VARCHAR(256),
@IBAN				CHAR(27),
@SWIFT				VARCHAR(32),
@IDDocID			INT,
@CustTransID		INT OUTPUT,
@CustTransTimeLoc	DATETIME OUTPUT,
@CustTransTimeUTC	DATETIME OUTPUT,
@BonificoID			INT OUTPUT
AS
--first some check on parameters
if not exists(select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID)
begin
	raiserror('Invalid CustomerID (%d) specified ',16,1,@CustID)
	RETURN 1
END
if @AmountCents is null or @AmountCents = 0
begin
	raiserror('Invalid Quantity specified',16,1)
	RETURN 1
END
if @CurrencyID is null or @CurrencyID NOT IN (0,4)
begin
	raiserror('Invalid @CurrencyID specified',16,1)
	RETURN 1
END

if not exists (select IDDocumentID from Snoopy.tbl_IDDocuments 
where IDDocumentID = @IDDocID 
and CustomerID = @CustID --must refer to the same customer of the banck account
)
begin
	raiserror('Invalid IDDocumentID (%d) specified or Document refers to a different customer',16,1,@IDDocID)
	RETURN 1
END
declare @GamingDate DATETIME,@Tag varchar(64),@DenoID INT,@IsFromEuroCredits bit

if @BonificoID is null 
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
		@GamingDate = GamingDate,
		@Tag = Tag
	FROM Snoopy.vw_AllBonifici 
	WHERE BonificoID = @BonificoID
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
if (@BankAddress is null or len(@BankAddress) = 0) and (@IBAN is null or len(@IBAN) = 0)
begin
	raiserror('Invalid Bank Address or IBAN specified',16,1)
	RETURN 1
END

--if a bank account id has not been provided check if bank account exists
--for that customer
if @BankAccountID is null 
	select @BankAccountID = BankAccountID
	from Snoopy.tbl_CustomerBankAccounts 
	Where CustomerID = @CustID  
	and BankName = @BankName
	and AccountNr = @BankAccountNr

declare @ret int
set @ret = 0


IF @CurrencyID = 0 
begin
	SET @DenoID = 187 --bonifico in EUR
	SET @IsFromEuroCredits = 1
end
ELSE IF @CurrencyID = 4
BEGIN
	SET @DenoID = 111 --bonifico in CHF
	SET @IsFromEuroCredits = 0
END

BEGIN TRANSACTION trn_Bonifici_CreateBonifico

BEGIN TRY  



if @BankAccountID is null
begin
	--insert a new back account information
	insert into Snoopy.tbl_CustomerBankAccounts 
	(
		CustomerID,
		BankName,
		AccountNr,
		IBAN,
		SWIFT,
		BankAddress
	)
	values
	(
		@CustID,
		@BankName,
		@BankAccountNr,
		@IBAN,
		@SWIFT,
		@BankAddress
	)
	SET @BankAccountID = SCOPE_IDENTITY()
END
ELSE	
BEGIN
	UPDATE Snoopy.tbl_CustomerBankAccounts
	SET BankName	= @BankName,
		AccountNr	= @BankAccountNr,
		IBAN		= @IBAN,
		SWIFT		= @SWIFT,
		BankAddress = @BankAddress
	WHERE CustomerID = @CustID AND BankAccountID = @BankAccountID
END

if @BonificoID is null -- we have to create a new bonifico transaction
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
	values
	(
		14, --Bonifico bancario
		@CustTransTimeUTC,
		@SourceLifeCycleID,
		@CustID,
		@UserAccessID
	)
	set @CustTransID = SCOPE_IDENTITY()
	
	--store bonifico importo
	INSERT INTO Snoopy.tbl_CustomerTransactionValues
	(
		DenoID,
		CustomerTransactionID,
		Quantity,
		ExchangeRate,
		CashInbound
	)
	VALUES(
		@DenoID, 
		@CustTransID,
		@AmountCents,
		1.0,	--ExchangeRate,
		1 --Bonifico is always inbound
		)
END
ELSE
BEGIN
	SELECT @CustTransID = OrderCustTransID
	FROM Snoopy.tbl_Bonifici
	WHERE BonificoID = @BonificoID
END



IF @BonificoID IS NULL -- we have to create a new bonifico transaction
BEGIN
	--now insert into Bonifici a new entry
	INSERT INTO Snoopy.tbl_Bonifici
	(
		BankAccountID,
		IDDocumentID,
		OrderCustTransID,
		IsFromEuroCredits
	)
	VALUES
	(
		@BankAccountID,
		@IDDocID,
		@CustTransID,
		@IsFromEuroCredits
	)
	SET @BonificoID = SCOPE_IDENTITY()
END
ELSE
BEGIN
	SET @CustTransTimeUTC = GETUTCDATE()

	--update bonifico information
	UPDATE Snoopy.tbl_Bonifici
		SET BankAccountID	 = @BankAccountID,
			IsFromEuroCredits = @IsFromEuroCredits
	WHERE BonificoID = @BonificoID
	
	UPDATE Snoopy.tbl_CustomerTransactions
	SET CustomerTransactionTime = @CustTransTimeUTC,
		UserAccessID			= @UserAccessID
	WHERE CustomerTransactionID = @CustTransID

	--update bonifico amount and excahnegrate
	UPDATE Snoopy.tbl_CustomerTransactionValues
	SET Quantity	=	@AmountCents,
		DenoID		= @DenoID
	WHERE CustomerTransactionID = @CustTransID
		
END


-- return cust transaction time in local hour
SET @CustTransTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@CustTransTimeUTC)



	COMMIT TRANSACTION trn_Bonifici_CreateBonifico

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_Bonifici_CreateBonifico
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
