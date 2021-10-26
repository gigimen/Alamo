SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_DeleteEuroTransaction]
@TransID	int,
@UserAccessID int
AS



--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specified',16,1,@UserAccessID)
	return 1
end

--the specified transaction must exists and must not be cancelled
if not exists (select TransactionID from Accounting.tbl_EuroTransactions where TransactionID = @TransID and CancelID is null)
begin
	raiserror('Invalid TransactionID (%d) specified or transaction already cancelled',16,1,@TransID)
	return 1
end


declare @CustID int,@ImportoCents int,@LifeCycleID int
select 
@CustID = CustomerID,
@ImportoCents = ImportoEuroCents,
@LifeCycleID = LifeCycleID 
FROM Accounting.tbl_EuroTransactions where TransactionID = @TransID and CancelID is null

--the specified transaction must exists and must be of type 12 (redemption)
if exists (select TransactionID from Accounting.tbl_EuroTransactions where TransactionID = @TransID and RedeemTransactionID is not null)
begin
	raiserror('Cannot delete a transaction that has been redeemed',16,1)
	return 1
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteEuroTransaction

BEGIN TRY  


	--first create cancel action
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(GetUTCDate(),@UserAccessID)

	declare @cancID int
	set @cancID = SCOPE_IDENTITY()

	update Accounting.tbl_EuroTransactions
		set CancelID = @cancID
	where TransactionID = @TransID

	--if we cancelled a redemption 
	if exists (select TransactionID from Accounting.tbl_EuroTransactions where TransactionID = @TransID and OpTypeID = 12)
	begin
	
		--mark as cancelled all ecash tickets redeemed by this redemption or vendita linked to this redemption
		update Accounting.tbl_EuroTransactions
			set CancelID = @cancID
		from Accounting.tbl_EuroTransactions,Accounting.tbl_LifeCycles
		where Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_EuroTransactions.LifeCycleID
			and (Accounting.tbl_LifeCycles.StockID = 56 or Accounting.tbl_EuroTransactions.OpTypeID = 13)
			and RedeemTransactionID = @TransID
	
		if @CustID is null --not a golden club redemption
		begin
			--mark as unreddemed all redempted acquisti excpet the ecash cambios
			update Accounting.tbl_EuroTransactions
				set RedeemTransactionID = null
			from Accounting.tbl_EuroTransactions,Accounting.tbl_LifeCycles
			where Accounting.tbl_LifeCycles.LifeCycleID = Accounting.tbl_EuroTransactions.LifeCycleID
				and Accounting.tbl_LifeCycles.StockID <> 56
				and OpTypeID = 11 --only for cambios
				and RedeemTransactionID = @TransID
		end
		else
		begin
			--here we do the same job for redemption but backward	
			--loop thru all cambio of the last 3 days 


			declare @days int
			declare @GamingDate datetime

			select @days = cast(VarValue as int) from [GeneralPurpose].[ConfigParams]
			 where VarName = 'EuroGoldenValidityDays'
			if @days is null
			begin
				raiserror ('Specify number of days in ConfigParams !!',16,1)
				--return 2
			end
			--print @days

			select @GamingDate = GamingDate from Accounting.tbl_LifeCycles
			where LifeCycleID = @LifeCycleID

			--print @GamingDate

			set @Gamingdate = @GamingDate - @days + 1

			--print @GamingDate
			--create the cursor
			set @ret =  CURSOR_STATUS ('global','acq_cursor')
			--print 'CURSOR_STATUS returned ' + cast(@ret as varchar)
			if @ret > -3
			begin
			--	print 'deallocting reg_cursor'
				DEALLOCATE acq_cursor
			end
			DECLARE acq_cursor CURSOR
			   FOR
					select 
						t.ImportoEuroCents,
						t.LeftToBeRedeemedCents,
						t.TransactionID
					from Accounting.tbl_EuroTransactions t
					inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = t.LifeCycleID
					where t.CustomerID = @CustID 
					and l.GamingDate >= @Gamingdate
					and CancelID is null
					and opTypeID = 11 --only acquisto
					and t.LeftToBeRedeemedCents < t.ImportoEuroCents --this was redeemed
					order by t.[InsertTimestamp] desc
				
			OPEN acq_cursor
			declare @acqTransID int,@acqLeftCents int,@qtyCents int

			FETCH NEXT FROM acq_cursor INTO @qtyCents,@acqLeftCents,@acqTransID
			WHILE (@@FETCH_STATUS <> -1 and @ImportoCents > 0)
			BEGIN
				
				if (@qtyCents - @acqLeftCents) <= @ImportoCents --this transaction has to be completely unredeemed
				begin
					update Accounting.tbl_EuroTransactions
						set LeftToBeRedeemedCents = @qtyCents 
					where TransactionID = @acqTransID
					set @ImportoCents = @ImportoCents - (@qtyCents - @acqLeftCents)
                    
					update Accounting.tbl_EuroTransactions
						set RedeemTransactionID = null
					where TransactionID = @acqTransID

					print 'Transaction ' + cast(@acqTransID as varchar(32)) + ' completely unredeemed'
				end
				else
				begin	
					--this is a partial unredemption 
					set @acqLeftCents = @acqLeftCents + @ImportoCents
					update Accounting.tbl_EuroTransactions
						set LeftToBeRedeemedCents = @acqLeftCents
					where TransactionID = @acqTransID

					set @ImportoCents = 0 --this will end the loop 
					print 'Transaction ' + cast(@acqTransID as varchar(32)) + ' partialy unredeemed'
				end
							
				FETCH NEXT FROM acq_cursor INTO @qtyCents,@acqLeftCents,@acqTransID
			END
			set @ret = CURSOR_STATUS ('global','acq_cursor')
			if @ret > -3
			begin
				--print 'deallocating acq_cursor'
				DEALLOCATE acq_cursor
			end

			if @ImportoCents > 0
			begin
				raiserror ('Left to be unredeemed(%d)!!',16,1,@ImportoCents)
			end
	
		
		
		
		end
	end		
	COMMIT TRANSACTION trn_DeleteEuroTransaction
	SET @ret = 0
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteEuroTransaction		
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
