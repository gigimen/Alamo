SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Accounting].[usp_NewEuroTransaction]
@OpTypeID	int,
@ImportoCents int,
@ExchangeRate float,
@LifeCycleID int,
@FrancsInRedemCents int,
@CustID int, -- Customer
@PhysicalEuros int,
@RedeemTransID int,
@UserAccessID int,
@TransID int output,
@TransTimeLoc datetime output
AS

if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	return 1
end


--first some check on parameters
if @OpTypeID is null or @OpTypeID not in (11,12,13)
begin
	raiserror('Invalid OpTypeID (%d) specified ',16,1,@OpTypeID)
	return 1
end
if @ExchangeRate is null or @ExchangeRate = 0
begin
	raiserror('Invalid ExchangeRate specified',16,1)
	return 1
end
--insert of a new transaction
if @LifeCycleID is null and not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID)
begin
	raiserror('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
	return 1
end

if @PhysicalEuros <> 0 and @PhysicalEuros <> 1
begin
	raiserror('Invalid PhysicalEuros (%d) specified ',16,1,@PhysicalEuros)
	return 1
end

if @custID is not null
begin
	--some check on the customer id 
	if not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID and CancelID is null and GoldenClubCardID is not null)
	begin
		raiserror('Invalid CustomerID (%d) specified or Customer is not a golden member ',16,1,@CustID)
		return 1
	end
end

if @ImportoCents is null or @Importocents = 0
begin
	raiserror('Invalid Importo€ specified ',16,1)
	return 1
end

--all redemption and vendita must specify the original value in francs
if ((@OpTypeID = 12 or @OpTypeID = 13) and (@FrancsInRedemCents is null or @FrancsInRedemCents = 0) ) or
(@OpTypeID = 11 and (@FrancsInRedemCents is not null and @FrancsInRedemCents > 0) ) 
begin
	raiserror('Invalid FrancsInRedemCents',16,1)
	return 1
end

if @OpTypeID = 12 --in case of a redemption run some more checks 
begin
	--first make sure we have a non redeemed transaction specified in not a free redemption
	if @CustID is null and not exists (select TransactionID from Accounting.tbl_EuroTransactions where TransactionID = @RedeemTransID and RedeemTransactionID is null and OpTypeID = 11)
	begin
		raiserror('Invalid cambio transaction to be redeemed specified',16,1)
		return 1
	end
end

declare @LeftTobeRedeemedCents int
set @LeftTobeRedeemedCents = null

if @OpTypeID = 11 and @CustID is not null --in case of an acquisto by a golden customer
	set @LeftTobeRedeemedCents = @ImportoCents

--now we can go

BEGIN TRANSACTION trn_InsertEuroTransaction

BEGIN TRY  


	if @TransID is null
	begin
		set @TransTimeLoc = GETUTCDATE()
		--create a new transaction
		insert into Accounting.tbl_EuroTransactions
		(
			LifeCycleID,
			OpTypeID,
			ImportoEuroCents,
			ExchangeRate,
			FrancsInRedemCents,
			PhysicalEuros,
			CustomerID,
			LeftToBeRedeemedCents,
			InsertTimestamp,
			UserAccessID
		)
		values(
			@LifeCycleID,
			@OpTypeID,
			@ImportoCents,
			@ExchangeRate,
			@FrancsInRedemCents,
			@PhysicalEuros,
			@CustID,
			@LeftTobeRedeemedCents,
			@TransTimeLoc,
			@UserAccessID
			)
		

		set @TransID = SCOPE_IDENTITY()
		if @OpTypeID = 12 and @RedeemTransID is not null
			--redeem acquisto transaction
			execute Accounting.usp_RedeemEuroTransaction @TransID,@RedeemTransID
				

		--if we are inserting a vendita mark also that is linked to the specified redemption
		if @OpTypeID = 13 and @RedeemTransID is not null
		update Accounting.tbl_EuroTransactions
		set RedeemTransactionID = @RedeemTransID
		where TransactionID = @TransID
		
	end
	else --update the existing transaction
	begin

		update Accounting.tbl_EuroTransactions
			set 		
			LifeCycleID				= @LifeCycleID,
			OpTypeID				= @OpTypeID,
			ImportoEuroCents		= @ImportoCents,
			ExchangeRate			= @ExchangeRate,
			FrancsInRedemCents		= @FrancsInRedemCents,
			PhysicalEuros			= @PhysicalEuros,
			CustomerID				= @CustID,
			LeftToBeRedeemedCents	= @LeftTobeRedeemedCents,
			UserAccessID			= @UserAccessID
		where TransactionID			= @TransID
		

		select @TransTimeLoc = InsertTimestamp from Accounting.tbl_EuroTransactions where TransactionID = @TransID

	end

	declare @tillDate datetime


	if @OpTypeID = 12 and @CustID is not null --in case of a redemption by a golden customer
	begin

		--loop thru all cambio of the last 3 days 


		declare @days int
		declare @GamingDate datetime

		select @days = cast(VarValue as int) from [GeneralPurpose].[ConfigParams]
		 where VarName = 'EuroGoldenValidityDays'
		if @days is null
		begin
			raiserror ('Specify number of days in [GeneralPurpose].[ConfigParams] !!',16,1)
			--return 2
		end
		--print @days

		select @GamingDate = GamingDate from Accounting.tbl_LifeCycles
		where LifeCycleID = @LifeCycleID

		--print @GamingDate
		set @tillDate = @GamingDate - @days + 1


		--print @GamingDate
		--create the cursor
		DECLARE @ret int
		set @ret = CURSOR_STATUS ('global','acq_cursor')
		--print 'CURSOR_STATUS returned ' + cast(@ret as varchar)
		if @ret > -3
		begin
		--	print 'deallocting reg_cursor'
			DEALLOCATE acq_cursor
		end
		DECLARE acq_cursor CURSOR
		   FOR
				select 
					t.LeftToBeRedeemedCents,
					t.TransactionID
				from Accounting.tbl_EuroTransactions t
				inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = t.LifeCycleID
				where t.CustomerID = @CustID 
				and l.GamingDate >= @tillDate
				and CancelID is null
				and opTypeID = 11 --only acquisto
				and t.LeftToBeRedeemedCents > 0 --there is something to be redeemed
				order by t.[InsertTimestamp]

		OPEN acq_cursor
		declare @acqTransID int
		declare @acqLeftCents int

		FETCH NEXT FROM acq_cursor INTO @acqLeftCents,@acqTransID
		WHILE (@@FETCH_STATUS <> -1 and @ImportoCents > 0)
		BEGIN
			if @acqLeftCents <= @ImportoCents --this transaction has been completely redeemed
			begin
				update Accounting.tbl_EuroTransactions
					set LeftToBeRedeemedCents = 0 
				where TransactionID = @acqTransID
				
				set @ImportoCents = @ImportoCents - @acqLeftCents
				--print 'Transaction ' + cast(@acqTransID as varchar(32)) + ' completely redeemed'
			end
			else
			begin	
				--this is a partial redemption because @importo holds too little money 
				set @acqLeftCents = @acqLeftCents - @ImportoCents
				update Accounting.tbl_EuroTransactions
					set LeftToBeRedeemedCents = @acqLeftCents
				where TransactionID = @acqTransID
				
				set @ImportoCents = 0 --this will end the loop 
				--print 'Transaction ' + cast(@acqTransID as varchar(32)) + ' partialy redeemed'
			end

			--update redemption info in the acquisto record
			update Accounting.tbl_EuroTransactions
					set RedeemTransactionID = @TransID
			where TransactionID = @acqTransID and RedeemTransactionID is null
			

			FETCH NEXT FROM acq_cursor INTO @acqLeftCents,@acqTransID
		END
		set @ret = CURSOR_STATUS ('global','acq_cursor')
		if @ret > -3
		begin
			--print 'deallocating acq_cursor'
			DEALLOCATE acq_cursor
		end

		if @ImportoCents > 0
		begin
			raiserror ('You asked for too much money. Left to be redeemed(%d)!!',16,1,@ImportoCents)
		end

	end







	if (@OpTypeID = 12 or @OpTypeID = 11) and @CustID is not null --in case of a redemption or an acquisto by a golden customer
	begin
		--return the list of availability for the next # days
		DECLARE @GoldenClubCardID int
		exec [GoldenClub].[usp_GetCustomerEuroAvailability]
			@LifeCycleID,
			@CustID,
			@GoldenClubCardID out
	end

	set @TransTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@TransTimeLoc)

	--commit the transaction now
	COMMIT TRANSACTION trn_InsertEuroTransaction

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_InsertEuroTransaction		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	return @ret
END CATCH


return 0


GO
