SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Accounting].[usp_GetEuroTransactions]
@LifeCycleID int
AS

DECLARE
@gaming	DATETIME,
@LastGamingDate DATETIME,
@StockID INT

--check input value
select 
	@StockID = StockID,
	@gaming = GamingDate 
FROM Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID


if @StockID is null
begin
	raiserror('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
	return 1
end


--first get euro present in Chiusura of previuos GamingDate

set @LastGamingDate = Accounting.fn_GetLastGamingDate(@StockID,1,DATEADD(dd,-1,@gaming))

select 
	et.TransactionID,
	et.RedeemTransactionID,
	CAST(et.ImportoEuroCents AS FLOAT) / 100 AS Quantity,
	et.FrancsInRedemCents,
	et.PhysicalEuros,
	et.ExchangeRate,
	et.GamingDate,
	et.StockTypeID,
	et.Tag,
	et.Multiplier,
	isnull(et.CustomerID,0) as CustomerID,
	et.GoldenClubCardID,
	et.OperationName,
	et.OpTypeID,
	et.ora,
	et.LeftToBeRedeemedCents,
	et.UtileCambio
from Accounting.[vw_AllEuroTransactions] et	
where et.LifeCycleID = @LifeCycleID 
union
select
	TransactionID, 
	null as RedeemTransactionID,
	isnull(sum(Quantity*Denomination),0) as Quantity,
	null as FrancsInRedemption,
	1 as PhysicalEuros,
	ExchangeRate,
	DestGamingDate as GamingDate,
	DestStockTypeID as StockTypeID,
	DestStockTag as Tag,
	+1 as Multiplier,
	0 as CustomerID,
	0 as GoldenClubCardID,
	OperationName,
	OpTypeID,
	DestTimeLoc as ora,
	0 as LeftToBeRedeemedCents,
	0 as UtileCambio
FROM Accounting.vw_AllTransactionDenominations
where DestLifeCycleID = @LifeCycleID
and ValueTypeID in (7,40) --euro banconote e monete
and OpTypeID = 5 -- ripristino
group by TransactionID, 
	OperationName,OpTypeID,
	DestTimeLoc,
	ExchangeRate,
	DestGamingDate,
	DestStockTypeID,
	DestStockTag
union
select
	LifeCycleSnapshotID AS TransactionID, 
	null as RedeemTransactionID,
	isnull(sum(Quantity*Denomination),0) as Quantity,
	null as FrancsInRedemption,
	1 as PhysicalEuros,
	ExchangeRate,
	GamingDate,
	StockTypeID,
	Tag,
	+1 as Multiplier,
	0 as CustomerID,
	0 as GoldenClubCardID,
	FName AS OperationName,
	SnapshotTypeID AS OpTypeID,
	SnapshotTimeLoc as ora,
	0 as LeftToBeRedeemedCents,
	0 as UtileCambio
from Accounting.vw_AllSnapshotDenominations 
        WHERE    (StockID = @StockID ) 
	AND (GamingDate = @LastGamingDate)
	and SnapshotTypeID = 3 --Chiusura
	and ValueTypeID in (7,40) --euro banconote e monete
group by LifeCycleSnapshotID, 
	FName,SnapshotTypeID,
	SnapshotTimeLoc,
	ExchangeRate,
	GamingDate,
	StockTypeID,
	Tag
union
--all acconti where i am the source of an account
select
	TransactionID, 
	null as RedeemTransactionID,
	isnull(sum(Quantity*Denomination),0) as Quantity,
	null as FrancsInRedemption,
	1 as PhysicalEuros,
	ExchangeRate,
	SourceGamingDate as GamingDate,
	SourceStockTypeID as StockTypeID,
	SourceTag as Tag,
	+1 as Multiplier,
	0 as CustomerID,
	0 as GoldenClubCardID,
	OperationName,
	OpTypeID,
	DestTimeLoc as ora,
	0 as LeftToBeRedeemedCents,
	0 as UtileCambio
FROM Accounting.vw_AllTransactionDenominations
where 
(
	--i am the source of an account
	SourceLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 1 --accont
	and DestLifeCycleID is not null --count only not pending transactions
) 
group by TransactionID, OperationName,OpTypeID,DestTimeLoc,
	ExchangeRate,
	SourceGamingDate,
	SourceStockTypeID,
	SourceTag
union
--all acconti where I am the destination of a versamento
select
	TransactionID, 
	null as RedeemTransactionID,
	isnull(sum(Quantity*Denomination),0) as Quantity,
	null as FrancsInRedemption,
	1 as PhysicalEuros,
	ExchangeRate,
	DestGamingDate as GamingDate,
	DestStockTypeID as StockTypeID,
	DestStockTag as Tag,
	+1 as Multiplier,
	0 as CustomerID,
	0 as GoldenClubCardID,
	OperationName + ' ' + sourceTag,
	OpTypeID,
	DestTimeLoc as ora,
	0 as LeftToBeRedeemedCents,
	0 as UtileCambio
FROM Accounting.vw_AllTransactionDenominations
where 
(
	--I am the destination of a versamento
	DestLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 4 --versamenti
)
group by TransactionID, OperationName,OpTypeID,sourceTag,DestTimeLoc,
	ExchangeRate,
	DestGamingDate,
	DestStockTypeID,
	DestStockTag
union all
--all versamenti where i am the source of a versamento
SELECT
	TransactionID, 
	null as RedeemTransactionID,
	isnull(sum(Quantity*Denomination),0) as Quantity,
	null as FrancsInRedemption,
	1 as PhysicalEuros,
	ExchangeRate,
	SourceGamingDate as GamingDate,
	SourceStockTypeID as StockTypeID,
	SourceTag as Tag,
	-1 as Multiplier,
	0 as CustomerID,
	0 as GoldenClubCardID,
	OperationName,
	OpTypeID,
	DestTimeLoc as ora,
	0 as LeftToBeRedeemedCents,
	0 as UtileCambio
from Accounting.vw_AllTransactionDenominations
where 
(
	--
	SourceLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 4 --versamenti
	and DestLifeCycleID is not null --count only not pending transactions
)
group by TransactionID, OperationName,OpTypeID,DestTimeLoc,
	ExchangeRate,
	SourceGamingDate ,
	SourceStockTypeID,
	SourceTag
union all
--all versamenti where i am the destiantion of versamento
select
	TransactionID, 
	null as RedeemTransactionID,
	isnull(sum(Quantity*Denomination),0) as Quantity,
	null as FrancsInRedemption,
	1 as PhysicalEuros,
	ExchangeRate,
	DestGamingDate as GamingDate,
	DestStockTypeID as StockTypeID,
	DestStockTag as Tag,
	-1 as Multiplier,
	0 as CustomerID,
	0 as GoldenClubCardID,
	OperationName + ' ' + sourceTag,
	OpTypeID,
	DestTimeLoc as ora,
	0 as LeftToBeRedeemedCents,
	0 as UtileCambio
from Accounting.vw_AllTransactionDenominations
where 
(
	--i am the destiantion of versamento
	DestLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 1 --accont
)
group by TransactionID, OperationName, OpTypeID,sourceTag,DestTimeLoc,
	ExchangeRate,
	DestGamingDate ,
	DestStockTypeID ,
	DestStockTag
/*

--add all acquisti
declare @acquisti int
declare @redemptions int
select @acquisti = isnull(sum(Quantity),0)
from dbo.EuroTransactions
where LifeCycleID = @LifeCycleID 
and OpTypeID = 11 -- it is an acquisto
print @acquisti

select @redemptions = isnull(sum(Quantity),0)
from dbo.EuroTransactions
where LifeCycleID = @LifeCycleID 
and OpTypeID = 12 -- it is a redemption

*/
return 0
GO
