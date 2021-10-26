SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_CalculateConsegna] 
@lfID			INT		,
@values			VARCHAR(max)
AS


if ( @lfID is null)
begin
	raiserror('Cannot specify a null @@lfID ',16,-1)
	RETURN (1)
end
if not exists (select LifeCycleID from Accounting.tbl_LifeCycles
	where LifeCycleID = @lfID and StockCompositionID is not null)
begin
	raiserror('Invalid @lfID %d',16,-1,@lfID)
	RETURN (1)
end

/*

set @values = '<ROOT>
<DENO denoid="1" qty="0" exrate="1.58" CashInbound="1" />
<DENO denoid="2" qty="4" exrate="1.58" CashInbound="0" />
<DENO denoid="3" qty="123" exrate="1.58" CashInbound="1" />
</ROOT>'
*/
declare @XML xml = @values,
@err int
set  @err = 0


declare 
@denoid int,
@qty int,
@exrate	float,
@CashInbound bit

SELECT  
	sc.StockCompositionID,
	lf.LifeCycleID,
	lf.GamingDate,
	lf.StockID, 
	st.Tag, 
	st.StockTypeID, 
	st.MinBet,
	CasinoLayout.StockTypes.FDescription AS StockTypeName,
	CasinoLayout.StockTypes.ChangeOfGamingDate,
	vt.ValueTypeID, 
	vt.FName AS ValueTypeName, 
	de.FName, 
	de.FDescription, 
	de.IsFisical, 
	de.Denomination, 
    de.DenoID, 
	de.DoNotDisplayQuantity,
	contgg.Quantity,
	code.InitialQty, 
	code.AutomaticFill,
	code.AllowNegative,
 	code.ModuleValue, 
	code.WeightInTotal, 
	cu.ExchangeRateMultiplier, 
    cu.IsoName AS CurrencyAcronim,
	cu.bd0 AS MinDenomination
FROM    Accounting.tbl_LifeCycles lf INNER JOIN CasinoLayout.Stocks st ON st.StockID = lf.StockID
INNER JOIN CasinoLayout.StockTypes ON CasinoLayout.StockTypes.StockTypeID = st.StockTypeID
INNER JOIN CasinoLayout.StockCompositions sc ON sc.StockCompositionID = lf.StockCompositionID
INNER JOIN CasinoLayout.StockComposition_Denominations code ON sc.StockCompositionID = code.StockCompositionID
INNER JOIN CasinoLayout.tbl_Denominations de ON code.DenoID = de.DenoID
INNER JOIN CasinoLayout.tbl_ValueTypes vt ON vt.ValueTypeID = de.ValueTypeID
INNER JOIN CasinoLayout.tbl_Currencies cu ON vt.CurrencyID = cu.CurrencyID
inner join
(
	SELECT 
			T.N.value('@denoid', 'int') AS denoid,
			T.N.value('@qty', 'int') AS [Quantity],
			T.N.value('@exrate', 'float') AS [ExchangeRate],
			T.N.value('@CashInbound', 'bit') AS CashInbound
		from @XML.nodes('ROOT/DENO') as T(N)
) contgg on contgg.denoid = de.DenoID
where lf.LifeCycleID = @lfID

RETURN 0

GO
