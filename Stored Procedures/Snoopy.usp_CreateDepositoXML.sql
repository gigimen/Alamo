SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Snoopy].[usp_CreateDepositoXML] 
@CustID int,
@SourceLifeCycleID int,
@UserAccessID int,
@values VARCHAR(MAX),
@depositoID INT OUTPUT,
@CustTransID int output,
@CustTransTime datetime output
AS

if @depositoID is null and not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @SourceLifeCycleID)
begin
	raiserror('Invalid LifeCycleID (%d) specified ',16,1,@SourceLifeCycleID)
	return 1
end
if @depositoID is null and @CustTransID IS NOT NULL
begin
	raiserror('Cannot specify a @CustTransID with a null @depositoID ',16,1)
	return 1
END
IF not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	return 1
end

--if we specify a deposito than we want to do a prelevamento
--make sure the deposito exists and is not been prelev yet
IF @depositoID is NOT NULL AND NOT EXISTS (
select	depOn.CustomerTransactionID
	from Snoopy.tbl_Depositi dep 
	INNER join Snoopy.tbl_CustomerTransactions depOn on depOn.CustomerTransactionID = dep.DepoCustTransID
	where dep.depositoID  = @depositoID 
	AND depOn.CustomerID = @CustID		--must be for the same customer
	AND dep.PrelevCustTransID IS NULL	--must not be prelevata yet
)
begin	
	raiserror('Cannot insert prelevamento for customer %d if deposito does not exists',16,1,@CustID)
	return 2
end

--if we specify a deposito make sure that the customer does not have already an active deposito
IF @depositoID is NULL AND EXISTS (
select	depOn.CustomerTransactionID
	from Snoopy.tbl_Depositi dep 
	INNER join Snoopy.tbl_CustomerTransactions depOn on depOn.CustomerTransactionID = dep.DepoCustTransID
	where depOn.CustomerID = @CustID	--must be for the same customer
	AND dep.PrelevCustTransID IS NULL	--must not be prelevata yet
)
begin	
	raiserror('Cannot insert versamento in deposito if customer %d has already a deposito',16,1,@CustID)
	return 2
end



declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateDepositoXML

BEGIN TRY  


	declare @XML xml = @values

	select 
	T.N.value('@denoid', 'int') as denoid,
	T.N.value('@qty', 'int') as qty,
	T.N.value('@exrate', 'float') as exrate,
	T.N.value('@CashInbound', 'bit') as CashInbound,
	T.N.value('@qty', 'int') * T.N.value('@exrate', 'float') as value
	from @XML.nodes('ROOT/DENO') as T(N)



	SET @CustTransTime = GetUTCDate()

	if @depositoID IS NULL --it is a deposito
	begin

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
			8, --'Deposito'
			@CustTransTime,
			@SourceLifeCycleID,
			@CustID,
			@UserAccessID)

		set @CustTransID = SCOPE_IDENTITY()

		--insert new deposito in deposito table
		insert into Snoopy.tbl_Depositi	(DepoCustTransID) values(@CustTransID)

		SET @depositoID = SCOPE_IDENTITY()

		--enter also the deposito composition
		insert into Snoopy.tbl_CustomerTransactionValues ([CustomerTransactionID],DenoID,Quantity,ExchangeRate,CashInbound)
		select 
			@CustTransID ,
			T.N.value('@denoid', 'int'),
			T.N.value('@qty', 'int'),
			T.N.value('@exrate', 'float'),
			1 --T.N.value('@CashInbound', 'bit')  ALWAYS Inbound in Deposito
		from @XML.nodes('ROOT/DENO') as T(N)

	end
	else	--it is a prelevamento
	begin
		insert into Snoopy.tbl_CustomerTransactions
		(
			OpTypeID,
			CustomerTransactionTime,
			SourceLifeCycleID,
			CustomerID,
			UserAccessID
		)
		values(
			8, --Deposito
			@CustTransTime,
			@SourceLifeCycleID,
			@CustID,
			@UserAccessID)

		set @CustTransID = @@IDENTITY
	
		--update depositi table
		update Snoopy.tbl_Depositi
		Set PrelevCustTransID = @CustTransID
		where DepositoID =	@depositoID


		--enter also the prelevamento composition
		insert into Snoopy.tbl_CustomerTransactionValues 
		([CustomerTransactionID],DenoID,Quantity,ExchangeRate,CashInbound)
		select 
			@CustTransID ,
			T.N.value('@denoid', 'int'),
			T.N.value('@qty', 'int'),
			T.N.value('@exrate', 'float'),
			0 --T.N.value('@CashInbound', 'bit') --ALWAYS Outbound in prelevemento
		from @XML.nodes('ROOT/DENO') as T(N)
	
	END


	-- return transaction time in local hour
	set @CustTransTime = GeneralPurpose.fn_UTCToLocal(1,@CustTransTime)

	COMMIT TRANSACTION trn_CreateDepositoXML

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateDepositoXML
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
