SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Accounting].[usp_SelectAllRipristino] 
@gaming datetime,
@bTrolleys int,
@toStockTypeID int
AS
if not exists (select LifeCycleID from Accounting.vw_AllStockLifeCycles 
	where GamingDate = @gaming AND StockID = 31 --'Main Stock'
	)
begin
	raiserror('MainStock lifecycleid does not exist  for specified gaming date',16,1)
	return (1)
end
if not exists (select StockTypeID from CasinoLayout.StockTypes 
	where StockTypeID = @toStockTypeID
	)
begin
	raiserror('Wrong StocktypeID specified',16,1)
	return (1)
end
declare @MSlfid int
select @MSlfid = LifeCycleID from Accounting.vw_AllStockLifeCycles 
	where GamingDate = @gaming  AND StockID = 31 --'Main Stock'

if @bTrolleys is not null and @bTrolleys > 0
	--return all ripristino generate by MainStock
	SELECT  
		ValueTypeName,
		ValueTypeID,
		Denomination,
		FDescription,
		DenoID,
		SUM(Quantity) as Quantity 
		FROM Accounting.vw_AllTransactionDenominations
		WHERE  OperationName = 'Ripristino'
		--generate by Main Stock
		AND SourceLifeCycleID = @MSlfid
		AND ValueTypeID in (1,2,3,36,42) --only gettoni,banconote,monete e gettoni euro
		and DestStockTypeID = @toStockTypeID
		GROUP BY DenoID,Denomination,FDescription,ValueTypeName,
		ValueTypeID
else
	SELECT  
		ValueTypeName,
		ValueTypeID,
		Denomination,
		FDescription,
		DenoID,
		SUM(Quantity) as Quantity 
		FROM Accounting.vw_AllTransactionDenominations
		WHERE  OperationName = 'Ripristino'
		--accepted by Main Stock
		AND DestLifeCycleID = @MSlfid
		AND ValueTypeID in (1,2,3,36,42) --only gettoni,banconote,monete e gettoni euro
		GROUP BY DenoID,Denomination,FDescription,ValueTypeName,
		ValueTypeID
GO
