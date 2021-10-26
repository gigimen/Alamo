SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [GoldenClub].[usp_GetCustomerEuroTransactions]
@GamingDate datetime,
@CustID int
AS


--first some check on parameters

if @CustID is null or not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID and CancelID is null and GoldenClubCardID is not null)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer is not a golden member ',16,1,@CustID)
	return 1
end

declare @days int


select @days = cast(VarValue as int) from [GeneralPurpose].[ConfigParams]
 where VarName = 'EuroGoldenValidityDays'
if @days is null
begin
	raiserror ('Specify number of days in [GeneralPurpose].[ConfigParams] !!',16,1)
	return 2
end
--print @days



set @GamingDate = @GamingDate - @days + 1

--print @GamingDate
select 
	et.LifeCycleID,
	et.TransactionID,
	et.ImportoEuroCents,
	CAST(et.ImportoEuroCents AS FLOAT) / 100 AS Quantity,
	et.FrancsInRedemCents,
	et.ExchangeRate,
	et.RedeemTransactionID,
	et.PhysicalEuros,
	et.CustomerID,
	et.LeftToBeRedeemedCents,
	case et.OpTypeID
	when 11 --acquisto
	then +1
	when 12 --redemption
	then -1
	when 13 --vendita
	then -1
	else 
	0
	end as Multiplier,
	g.GoldenClubCardID,
	ot.FName as OperationName,
	l.GamingDate,
	s.Tag,
	GeneralPurpose.fn_UTCToLocal(1,et.InsertTimestamp) as ora
 from Accounting.tbl_EuroTransactions et
 inner join GoldenClub.tbl_Members g on g.CustomerID = et.CustomerID
 inner join CasinoLayout.OperationTypes ot on ot.OpTypeID = et.OpTypeID
 inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = et.LifeCycleID
 inner join CasinoLayout.Stocks s on s.StockID = l.StockID
 where et.CustomerID = @CustID 
 and l.GamingDate >= @GamingDate
 and et.CancelID is null
 order by et.[InsertTimestamp] desc
 
 /*
select 
	et.TransactionID,
	et.RedeemTransactionID,
	et.Quantity,
	et.FrancsInRedemCents,
	et.PhysicalEuros,
	et.ExchangeRate,
	et.LeftToBeRedeemed,
	l.GamingDate,
	s.StockTypeID,
	s.Tag,
	case et.OpTypeID
	when 11 --acquisto
	then +1
	when 12 --redemption
	then -1
	when 13 --vendita
	then -1
	else 
	0
	end as Multiplier,
	isnull(et.CustomerID,0) as CustomerID,
	ot.FName as OperationName,
	[GeneralPurpose].[fn_UTCToLocal](1,et.InsertTimestamp) as ora
from dbo.EuroTransactions et	
inner join dbo.OperationTypes ot on ot.OpTypeID = et.OpTypeID
inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = et.LifeCycleID
inner join Stocks s on s.StockID = l.StockID
where et.CustomerID = @CustID 
and l.GamingDate >= @GamingDate
and et.CancelID is null
order by et.[InsertTimestamp] asc
*/
return 0
GO
