SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Accounting].[usp_SelectAllConsegna] 
@gaming datetime,
@bAccepted int,
@fromStockTypeID int
AS
if not exists (select LifeCycleID from Accounting.vw_AllStockLifeCycles 
	where GamingDate = @gaming
	and Tag = 'Main Stock'
	)
begin
	raiserror('MainStock lifecycleid does not exist  for specified gaming date',16,1)
	return (1)
end
if not exists (select StockTypeID from CasinoLayout.StockTypes 
	where StockTypeID = @fromStockTypeID
	)
begin
	raiserror('Wrong StocktypeID specified',16,1)
	return (1)
end
declare @MSlfid int
select @MSlfid = LifeCycleID from Accounting.vw_AllStockLifeCycles 
	where GamingDate = @gaming AND StockID = 31 --main stock
if @bAccepted is not null and @bAccepted > 0
	SELECT  ValueTypeName,
		ValueTypeID,
		Denomination,
		FDescription,
		DenoID,
		SUM(Quantity) as Quantity 
		FROM Accounting.vw_AllTransactionDenominations
		WHERE  OperationName = 'ConsegnaPerRipristino'
		AND DestLifeCycleID = @MSlfid
		AND ValueTypeID in (1,2,3,36,42) --only gettoni,banconote,monete e gettoni euro
		and SourceStockTypeID = @fromStockTypeID
		GROUP BY DenoID,Denomination,FDescription,ValueTypeName,
		ValueTypeID
else
	SELECT  ValueTypeName,
		ValueTypeID,
		Denomination,
		FDescription,
		DenoID,
		SUM(Quantity) as Quantity 
		FROM Accounting.vw_AllTransactionDenominations
		WHERE  OperationName = 'ConsegnaPerRipristino'
		--not yet accepted
		AND DestLifeCycleID is null
		--but created the same gamin date of the main stock
		AND SourceGamingDate = @gaming
		AND ValueTypeID in (1,2,3,36,42) --only gettoni,banconote,monete e gettoni euro
		and SourceStockTypeID = @fromStockTypeID
		GROUP BY DenoID,Denomination,FDescription,ValueTypeName,
		ValueTypeID
GO
