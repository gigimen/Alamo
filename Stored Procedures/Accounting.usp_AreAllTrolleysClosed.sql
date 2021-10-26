SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_AreAllTrolleysClosed] 
@gaming datetime,
@alsoCC	int,
@nTrolleys int output
AS
if @alsoCC = 1
	select @nTrolleys = count(*)
	from Accounting.vw_AllStockLifeCycles
	where GamingDate = @gaming
	and CloseTime is null
	and StockTypeID in 
		( 
			select StockTypeID from CasinoLayout.StockTypes 
			where FDescription = 'Trolleys'
			or FDescription = 'Main Trolleys'
		)
else
	select @nTrolleys = count(*)
	from Accounting.vw_AllStockLifeCycles
	where GamingDate = @gaming
	and CloseTime is null
	and StockTypeID in 
		( 
			select StockTypeID from CasinoLayout.StockTypes 
			where FDescription = 'Trolleys'
		)

if @nTrolleys is null
	set @nTrolleys = 0
if @alsoCC = 1
	select Tag
	from Accounting.vw_AllStockLifeCycles
	where GamingDate = @gaming
	and CloseTime is null
	and StockTypeID in 
		( 
			select StockTypeID from CasinoLayout.StockTypes 
			where FDescription = 'Trolleys'
			or FDescription = 'Main Trolleys'
		)
else
	select Tag
	from Accounting.vw_AllStockLifeCycles
	where GamingDate = @gaming
	and CloseTime is null
	and StockTypeID in 
		( 
			select StockTypeID from CasinoLayout.StockTypes 
			where FDescription = 'Trolleys'
		)
GO
