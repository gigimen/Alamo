SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [Accounting].[usp_UpdateConteggioXML] 
@ConteggioID	INT		,
@values			VARCHAR(max),
@UAID			INT	
AS


if ( @ConteggioID is null)
begin
	raiserror('Cannot specify a null @ConteggioID ',16,-1)
	RETURN (1)
end
/*

set @values = '<ROOT>
<DENO denoid="153" stockid="5" exrate="1.000000" qty="1" />
<DENO denoid="22" stockid="6" exrate="1.000000" qty="2" />
<DENO denoid="78" stockid="6" exrate="1.000000" qty="10" />
<DENO denoid="155" stockid="7" exrate="1.040000" qty="3" />
</ROOT>'
*/

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_UpdateConteggioXML

BEGIN TRY  
	
	declare @XML xml = @values

	declare 
	@DenoID int,
	@StockID int,
	@newQty int,
	@oldQty INT ,
	@newExrate	float,
	@oldExRate float

	
	--update only Conteggio values
	declare exclu_cursor cursor for
		select	isnull(n.DenoID,v.DenoID) as DenoID,
				isnull(n.StockID,v.StockID) as StockID,
				isnull(n.[Quantity],0) as NewQuantity,
				isnull(v.[Quantity],0) as OldQuantity,
				n.[ExchangeRate],
				v.[ExchangeRate]
		from 
		(
			SELECT 
				T.N.value('@denoid', 'int') AS DenoID,
				T.N.value('@stockid', 'int') AS StockID,
				cast(T.N.value('@qty', 'float') as Int) AS [Quantity],
				--T.N.value('@qty', 'int') AS [Quantity],
				T.N.value('@exrate', 'float') AS [ExchangeRate]
			from @XML.nodes('ROOT/DENO') as T(N)
		)n
		FULL OUTER JOIN 
		(
			SELECT 
				DenoID,
				StockID,
				[Quantity],
				[ExchangeRate]
			from Accounting.tbl_ConteggiValues t
			where ConteggioID = @ConteggioID 
		) v ON n.DenoID = v.DenoID and n.StockID = v.StockID
		WHERE NOT (v.DenoID IS NULL AND n.[Quantity] = 0) AND NOT (n.[Quantity] is not null and v.[Quantity] is not null and n.[Quantity] = v.[Quantity]) 

	Open exclu_cursor

	Fetch Next from exclu_cursor into @DenoID ,@StockID ,@newQty ,@oldQty  ,@newExrate	,@oldExRate 
	DECLARE @ModID INT
	IF @DenoID IS NOT NULL
	BEGIN

		INSERT INTO [FloorActivity].[tbl_ConteggiModifications]
					([UserAccessID]
					,[ConteggioID])
		VALUES(
				@UAID,
				@ConteggioID)

	
		SET @ModID = @@IDENTITY

		While @@FETCH_STATUS = 0  
		Begin
			--use the existing DenoID
	
			if @OldExrate is null 
				set @OldExrate = @newExrate  

			--if both old and new are different than we have to apply the change
			if @newQty <> @oldQty
			BEGIN
				--is it an update or a delete?
				IF @newQty <> 0  
				begin
			
						if @newExrate is null 
						begin
							ROLLBACK TRANSACTION UpdateConteggio	
							raiserror('Cannot specify a null @exchangerate ',16,-1)
							RETURN (1)
						end
					
						if @oldQty = 0
						begin
						
							--it is a new Denomination in the set
							INSERT INTO [Accounting].[tbl_ConteggiValues]
								   ([ConteggioID]
								   ,[DenoID]
								   ,[StockID]
								   ,[Quantity]
								   ,[ExchangeRate])
							VALUES( 
									@ConteggioID,
									@DenoID,
									@StockID,
									@newQty,
									@newExrate
									)

							print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value added'		
						end
						else --this is a real update of an existing one
						begin
							--update to new value
							update Accounting.tbl_ConteggiValues 
									set Quantity = @newQty,
									ExchangeRate = @newExrate
									where ConteggioID = @ConteggioID and DenoID = @DenoID and StockID = @StockID
	
							print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value updated'		
						end
				end 
				else
				begin--delete the value that now is 0
					DELETE FROM Accounting.tbl_ConteggiValues 
					where ConteggioID = @ConteggioID and DenoID = @DenoID and StockID = @StockID

					print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value deleted'	
				END
			
				--insert a new entry in [FloorActivity].[tbl_ConteggioValuesModifications] to record the change of value
				INSERT INTO [FloorActivity].[tbl_ConteggioValuesModifications]
					([ModID]
					,[DenoID]
					,[StockID]
					,[FromQuantity]
					,[ToQuantity]
					,[ExchangeRate])
					VALUES
					(@ModID,
					@DenoID,
					@StockID,
					@oldQty,
					@newQty,
					@OldExrate)
			end
			Fetch Next from exclu_cursor into @DenoID ,@StockID ,@newQty ,@oldQty  ,@newExrate	,@oldExRate 
		End
	END

	close exclu_cursor
	deallocate exclu_cursor

	
	COMMIT TRANSACTION trn_UpdateConteggioXML

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateConteggioXML	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
