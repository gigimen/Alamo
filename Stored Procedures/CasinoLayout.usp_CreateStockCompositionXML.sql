SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [CasinoLayout].[usp_CreateStockCompositionXML]
@StockID int,
@CompName varchar(64),
@values		VARCHAR(MAX),
--@UserAccessID int,
@newStockcompID int output
AS
if (@StockID is null or not exists (select StockID from CasinoLayout.Stocks where StockID=@StockID))
begin
	raiserror('Invalid StockID %d specified',16,-1,@StockID)
	return (1)
end
if (@CompName is null or LEN(@CompName)=0)
begin
	raiserror('Must specify a new composition name',16,-1)
	return (1)
end


/*
declare @t as varchar(max)
set @t = '<ROOT>
<DENO denoid="1" qty="0" />
<DENO denoid="2" qty="4" />
<DENO denoid="3" qty="123" />
</ROOT>'
declare @XML xml = @t
select 
T.N.value('@denoid', 'int') as DenoID,
T.N.value('@qty', 'int') as qty
from @XML.nodes('ROOT/DENO') as T(N)
*/

--get current stock composition for the specified StockID
declare @oldStockcompID INT
select @oldStockcompID = StockCompositionID 
from CasinoLayout.[tbl_StockComposition_Stocks]
where StockID = @StockID AND EndOfUseGamingDate IS null

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateStockCompositionXML

BEGIN TRY  


	DECLARE @ti DATETIME
	SET @ti = GETUTCDATE()



	--create the new stock composition first
	INSERT INTO CasinoLayout.StockCompositions 	
		(
			FName,
			CreationDate
		) 
		VALUES
		(
			@CompName,
			@ti
		)

	select @newStockcompID = SCOPE_IDENTITY( )
	--print 'New composition id ' + str(@newStockcompID)



	--mark end of use of old composition
	if @oldStockcompID is not null	
	begin

		--terminate old stock composition definition
		SET @ti = GeneralPurpose.fn_GetGamingLocalDate2(@ti,1,6)

		UPDATE [CasinoLayout].[tbl_StockComposition_Stocks]
		   SET [EndOfUseGamingDate] = DATEADD(DAY,-1,@ti)
		WHERE StockCompositionID = @oldStockcompID AND [EndOfUseGamingDate] IS null
    
	end

	INSERT INTO [CasinoLayout].[tbl_StockComposition_Stocks]
				([StockCompositionID]
				,[StockID]
				,[StartOfUseGamingDate])
	VALUES(
			@newStockcompID
			,@StockID
			,@ti)


	IF @values is NOT NULL AND LEN(@values) > 0
	begin
		EXEC [CasinoLayout].[usp_UpdateStockCompositionXML]
					@newStockcompID,
					@values	
	END

	--copy over all Denomination which are not fisical and were present in old composition
	if @oldStockcompID is not null	
	begin
		declare @XML xml = @values

		--print 'existing composition id ' + str(@oldStockcompID)
		insert into CasinoLayout.StockComposition_Denominations
		(
			StockCompositionID,
			DenoID,
			InitialQty,
			ModuleValue,
			WeightInTotal,
			AllowNegative,
			AutomaticFill		
		)
		select @newStockcompID,
			scd.DenoID,
			InitialQty,
			ModuleValue,
			WeightInTotal,
			AllowNegative,
			AutomaticFill
		from CasinoLayout.StockComposition_Denominations scd
		INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = scd.DenoID
		where scd.StockCompositionID = @oldStockcompID
		AND d.IsFisical = 0 AND d.DenoID NOT IN
        (		
			SELECT T.N.value('@denoid', 'int') as DenoID
			from @XML.nodes('ROOT/DENO') as T(N)
		)

	end

	COMMIT TRANSACTION trn_CreateStockCompositionXML

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateStockCompositionXML
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
