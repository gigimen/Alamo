SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE procedure [CasinoLayout].[usp_UpdateStockCompositionXML]
@stockCompID	INT,
@values			VARCHAR(max)
AS

IF NOT EXISTS (select StockCompositionID from CasinoLayout.StockCompositions where StockCompositionID = @stockCompID  )
BEGIN
	RAISERROR('Unexisting StockCompositionID (%d) specified',16,1,@stockCompID)
	RETURN 1
END
IF @values IS NULL OR LEN(@values) = 0
BEGIN
	--nothing to be updated
	RETURN 0
end
/*
set @values = '<ROOT>
<DENO denoid="93"  qty="34600 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="40500 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="41500 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="41000 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="42000 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="41000 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="51000 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="37000 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="47000 mod="1" weigth="1" autofill="1" "/>
<DENO denoid="93"  qty="41100 mod="1" weigth="1" autofill="1" "/>
</ROOT>'
*/
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_UpdateStockCompositionXML

BEGIN TRY  



declare @XML xml = @values


declare 
@DenoID int,
@OldDenoid INT,
@InitialQty		INT,
@ModuleValue	INT,
@WeightInTotal	INT,
@AutomaticFill	INT,
@AllowNegative	INT




if CURSOR_STATUS ('global','comp_cursor') > -3
	DEALLOCATE comp_cursor

	
--update stock composition values
declare comp_cursor cursor for
	select	n.DenoID,
			v.DenoID,
			n.InitialQty	,
			n.ModuleValue	,
			n.WeightInTotal	,
			n.AutomaticFill	,
			n.AllowNegative
 	from 
	(
		SELECT 
			T.N.value('@denoid', 'int')		AS DenoID,
			T.N.value('@qty', 'int')		AS InitialQty,
			T.N.value('@mod', 'int')		AS ModuleValue,
			T.N.value('@weight', 'int')		AS WeightInTotal,
			T.N.value('@autofill', 'int')	AS AutomaticFill,
			T.N.value('@allowNeg', 'int')	AS AllowNegative
		from @XML.nodes('ROOT/DENO') as T(N)
	)n
	FULL OUTER JOIN 
	(
		SELECT DenoID
		from CasinoLayout.StockComposition_Denominations t
		WHERE StockCompositionID = @stockCompID 
	) v ON n.DenoID = v.DenoID
Open comp_cursor

Fetch Next from comp_cursor into 
		@DenoID			,
		@OldDenoid		,
		@InitialQty		,
		@ModuleValue	,
		@WeightInTotal	,
		@AutomaticFill	,
		@AllowNegative	 
While @@FETCH_STATUS = 0 
Begin
		if @OldDenoid is null
		begin
			--it is a new Denomination in the set

			INSERT INTO [CasinoLayout].[StockComposition_Denominations]
					   ([StockCompositionID]
					   ,[DenoID]
					   ,[InitialQty]
					   ,[ModuleValue]
					   ,[WeightInTotal]
					   ,[AutomaticFill]
					   ,[AllowNegative])
				 VALUES
					   (@stockCompID 
					   ,@DenoID
					   ,@InitialQty
					   ,@ModuleValue
					   ,@WeightInTotal
					   ,@AutomaticFill
					   ,@AllowNegative)
			print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value added'		
		end
		else IF @DenoID IS not NULL
		BEGIN --this is a real update of an existing one
			--update to new value
			UPDATE [CasinoLayout].[StockComposition_Denominations]
			SET [InitialQty]		= @InitialQty
			  ,[ModuleValue]	= @ModuleValue
			  ,[WeightInTotal]	= @WeightInTotal
			  ,[AutomaticFill]	= @AutomaticFill
			  ,[AllowNegative]	= @AllowNegative
			WHERE StockCompositionID = @stockCompID and DenoID = @DenoID
			print 'DenoID ' + cast(@DenoID as varchar(32)) + ' value updated'		
		end 
		ELSE --delete the value that now is missing
		begin
				delete from CasinoLayout.StockComposition_Denominations 
				where StockCompositionID = @stockCompID and DenoID = @OlddenoID
				print 'DenoID ' + cast(@OlddenoID as varchar(32)) + ' value deleted'		
		END
		Fetch Next from comp_cursor into 
			@DenoID			,
			@OldDenoid		,
			@InitialQty		,
			@ModuleValue	,
			@WeightInTotal	,
			@AutomaticFill	,
			@AllowNegative	  
End

close comp_cursor
deallocate comp_cursor

	COMMIT TRANSACTION trn_UpdateStockCompositionXML

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateStockCompositionXML
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
