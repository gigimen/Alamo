SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_UpdateTransactionXML] 
@TransID		INT		,
@values			VARCHAR(max),
@UAID			INT	
AS


if ( @TransID is null)
begin
	raiserror('Cannot specify a null @TransID ',16,-1)
	RETURN (1)
end
	select * from Accounting.tbl_TransactionValues
	where TransactionID = @transID 
/*

set @values = '<ROOT>
<DENO denoid="1" qty="0" exrate="1.58" CashInbound="1" />
<DENO denoid="2" qty="4" exrate="1.58" CashInbound="0" />
<DENO denoid="3" qty="123" exrate="1.58" CashInbound="1" />
</ROOT>'
*/

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_UpdateTransaction

BEGIN TRY  

	declare @XML xml = @values



	declare 
	@DenoID int,
	@OldDenoid int,
	@qty int,
	@oldQty INT ,
	@exrate	float,
	@oldExRate float,
	@CashInbound bit,
	@OldCashInbound bit 

	
	--update only transaction values
	declare exclu_cursor cursor for
		select	n.DenoID,
				v.DenoID,
				n.[Quantity],
				v.[Quantity],
				n.[ExchangeRate],
				v.[ExchangeRate],
				n.CashInbound,
				v.CashInbound 
		from 
		(
			SELECT 
				T.N.value('@denoid', 'int') AS DenoID,
				--T.N.value('@qty', 'int') AS [Quantity],
				cast(T.N.value('@qty', 'float') as Int) AS [Quantity],
				T.N.value('@exrate', 'float') AS [ExchangeRate],
				T.N.value('@CashInbound', 'bit') AS CashInbound
			from @XML.nodes('ROOT/DENO') as T(N)
		)n
		FULL OUTER JOIN 
		(
			SELECT 
				DenoID,
				[Quantity],
				[ExchangeRate],
				CashInbound
			from Accounting.tbl_TransactionValues t
			where TransactionID = @transID 
		) v ON n.DenoID = v.DenoID AND  n.CashInbound = v.CashInbound
		WHERE NOT (v.DenoID IS NULL AND n.[Quantity] = 0) AND NOT (n.[Quantity] is not null and v.[Quantity] is not null and n.[Quantity] = v.[Quantity]) 

	Open exclu_cursor

	Fetch Next from exclu_cursor into @DenoID ,@OldDenoid ,@qty ,@oldQty ,@exrate,@oldExRate ,@CashInbound ,@OldCashInbound  
	While @@FETCH_STATUS = 0 
	Begin
		--use the existing DenoID
	
		if @oldQty is null 
		begin
			set @oldQty = 0
			set @OldExrate = @exrate  
		end		
	
		if @qty is null
		begin
			set @qty = 0
		end		
		--if both old and new are different than we have to apply the change
		if @qty <> @oldQty
		BEGIN
			--is it an update or a delete?
			IF @qty <> 0  
			begin
					if @OldDenoid is null
					begin
					--it is a new Denomination in the set
						insert into Accounting.tbl_TransactionValues 
						(TransactionID,DenoID,Quantity,ExchangeRate,CashInbound)
						values( @transID,@DenoID,@qty,@exrate,@CashInbound)
					
						--print 'DenoID ' + cast(@DenoID as varchar(32)) + ' ' + cast(@CashInbound as varchar(32)) + ' value added'		
					end
					else --this is a real update of an existing one
					begin
						--update to new value
						update Accounting.tbl_TransactionValues 
								set Quantity = @qty,
								ExchangeRate = @exrate
								where TransactionID = @transID and DenoID = @DenoID AND CashInbound = @CashInbound
					
						--print 'DenoID ' + cast(@DenoID as varchar(32)) + ' ' + cast(@CashInbound as varchar(32)) + ' value updated'		
					end
			end 
			else
			begin--delete the value that now is 0
				if @DenoID is null
				begin
					set @DenoID = @olddenoid
					set @CashInbound = @OldCashInbound
				end	
			
				DELETE FROM Accounting.tbl_TransactionValues 
				where TransactionID = @transID and DenoID = @DenoID AND CashInbound = @CashInbound
		
				--print 'DenoID ' + cast(@DenoID as varchar(32)) + ' ' + cast(@CashInbound as varchar(32)) + ' value deleted'		
			END
			
			--insert a new entry in [FloorActivity].[TransactionModifications] to record the change of value
				INSERT INTO FloorActivity.tbl_TransactionModifications
						(UserAccessID
						,[TransactionID]
						,[DenoID]
						,CashInbound
						,[FromQuantity]
						,[ToQuantity]
						,[ExchangeRate])
				VALUES
						(
						@UAID,
						@transID,
						@DenoID,
						@CashInbound,
						@oldQty,
						@qty,
						@OldExrate)
		end
		Fetch Next from exclu_cursor into @DenoID ,@OldDenoid ,@qty ,@oldQty ,@exrate,@oldExRate ,@CashInbound ,@OldCashInbound  
	End

	close exclu_cursor
	deallocate exclu_cursor


	COMMIT TRANSACTION trn_UpdateTransaction
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateTransaction	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
