SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Snoopy].[usp_CreateBonifico]
@CustID			int,
@EuroCents		int,
@IsFromEuroCredits bit,
@ExchangeRate float,	
@SourceLifeCycleID int,
@UserAccessID int,
@BankAccountID int output,
@BankAccountNr varchar(64),
@BankName varchar(256),
@BankAddress varchar(256),
@IBAN char(27),
@SWIFT varchar(32),
@IDDocID int,
@CustTransID int output,
@CustTransTimeLoc datetime output,
@CustTransTimeUTC datetime output,
@BonificoID int output
AS
--first some check on parameters
if not exists(select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID)
begin
	raiserror('Invalid CustomerID (%d) specified ',16,1,@CustID)
	return 1
end
if @EuroCents is null or @EuroCents = 0
begin
	raiserror('Invalid Quantity specified',16,1)
	return 1
end
if @ExchangeRate is null or @ExchangeRate = 0
begin
	raiserror('Invalid ExchangeRate specified',16,1)
	return 1
end

if not exists (select IDDocumentID from Snoopy.tbl_IDDocuments 
where IDDocumentID = @IDDocID 
and CustomerID = @CustID --must refer to the same customer of the banck account
)
begin
	raiserror('Invalid IDDocumentID (%d) specified or Document refers to a different customer',16,1,@IDDocID)
	return 1
end
declare @GamingDate datetime
declare @Tag varchar(64)

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
		return 1
	end
	--get gaming date and Tag from LifeCles table
	select 
		@GamingDate = Accounting.tbl_LifeCycles.GamingDate,
		@Tag = CasinoLayout.Stocks.Tag
	from Accounting.tbl_LifeCycles 
	inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
	where LifeCycleID = @SourceLifeCycleID 
end
else
begin
	--get gaming date and Tag from LifeCles table
	select 
		@GamingDate = GamingDate,
		@Tag = Tag
	from Snoopy.vw_AllBonifici 
	where BonificoID = @BonificoID
end


if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	return 1
end

if @BankAccountNr is null or len(@BankAccountNr) = 0
begin
	raiserror('Invalid BankAccountNr specified',16,1)
	return 1
end

if @BankName is null or len(@BankName) = 0
begin
	raiserror('Invalid Bank Name specified',16,1)
	return 1
end
if (@BankAddress is null or len(@BankAddress) = 0) and (@IBAN is null or len(@IBAN) = 0)
begin
	raiserror('Invalid Bank Address or IBAN specified',16,1)
	return 1
end

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

BEGIN TRANSACTION trn_CreateBonifico

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
	set @BankAccountID = SCOPE_IDENTITY()
end
else	
BEGIN
	update Snoopy.tbl_CustomerBankAccounts
	set BankName	= @BankName,
		AccountNr	= @BankAccountNr,
		IBAN		= @IBAN,
		SWIFT		= @SWIFT,
		BankAddress = @BankAddress
	where CustomerID = @CustID and BankAccountID = @BankAccountID
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
	insert into Snoopy.tbl_CustomerTransactionValues
	(
		DenoID,
		CustomerTransactionID,
		Quantity,
		ExchangeRate,
		CashInbound
	)
	values(
		111, --bonifico bancario
		@CustTransID,
		@EuroCents,
		@ExchangeRate,
		1 --Bonifico is always inbound
		)
end
else
begin
	select @CustTransID = OrderCustTransID
	from Snoopy.tbl_Bonifici
	where BonificoID = @BonificoID
end



if @BonificoID is null -- we have to create a new bonifico transaction
begin
	--now insert into Bonifici a new entry
	insert into Snoopy.tbl_Bonifici
	(
		BankAccountID,
		IDDocumentID,
		OrderCustTransID,
		IsFromEuroCredits
	)
	values
	(
		@BankAccountID,
		@IDDocID,
		@CustTransID,
		@IsFromEuroCredits
	)
	set @BonificoID = SCOPE_IDENTITY()
end
else
begin
	set @CustTransTimeUTC = GetUTCDate()

	--update bonifico information
	update Snoopy.tbl_Bonifici
		set BankAccountID	 = @BankAccountID,
			IsFromEuroCredits = @IsFromEuroCredits
	where BonificoID = @BonificoID
	
	update Snoopy.tbl_CustomerTransactions
	set CustomerTransactionTime = @CustTransTimeUTC,
		UserAccessID			= @UserAccessID
	where CustomerTransactionID = @CustTransID

	--update bonifico amount and excahnegrate
	update Snoopy.tbl_CustomerTransactionValues
	set Quantity		=	@EuroCents,
		ExchangeRate	=	@ExchangeRate
	where CustomerTransactionID = @CustTransID
	and DenoID = 111 --bonifico Denomination
		
end


-- return cust transaction time in local hour
set @CustTransTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@CustTransTimeUTC)



	COMMIT TRANSACTION trn_CreateBonifico

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateBonifico
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
