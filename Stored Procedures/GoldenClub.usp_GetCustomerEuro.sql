SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_GetCustomerEuro]
@CustomerID int,
@LifeCycleID int,
@TotEuros float output
AS


--insert of a new transaction
if @CustomerID is null and not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustomerID  and CancelID is null and GoldenClubCardID is not null)
begin
	raiserror('Invalid CustomerID (%d) specified ',16,1,@CustomerID)
	return 1
end

declare @days int
declare @GamingDate datetime

select @days = cast(VarValue as int) from [GeneralPurpose].[ConfigParams]
 where VarName = 'EuroGoldenValidityDays'
if @days is null
begin
	raiserror ('ISpecify number of days in [GeneralPurpose].[ConfigParams] !!',16,1)
	return 2
end
--print @days

select @GamingDate = GamingDate from Accounting.tbl_LifeCycles
where LifeCycleID = @LifeCycleID

--print @GamingDate
declare @tillDate datetime
set @tillDate = @GamingDate - @days + 1

--print @GamingDate

select @TotEuros = isNull(SUM( CAST(t.LeftToBeRedeemedCents AS FLOAT) / 100),0)
from Accounting.tbl_EuroTransactions t
inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = t.LifeCycleID
where t.CustomerID = @CustomerID 
and l.GamingDate >= @tillDate
and t.CancelID is null
and t.OpTypeID = 11 --count only acquisti

if @TotEuros is null
	set @TotEuros = 0



/*
select 
	et.TransactionID,
	et.Quantity,
	et.FrancsInRedemption,
	et.ExchangeRate,
	et.LeftToBeRedeemed,
	l.GamingDate,
	s.Tag,
	ot.FName as OperationName,
	[GeneralPurpose].[fn_UTCToLocal](1,et.InsertTimestamp) as ora
from dbo.EuroTransactions et	
inner join dbo.OperationTypes ot on ot.OpTypeID = et.OpTypeID
inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = et.LifeCycleID
inner join Stocks s on s.StockID = l.StockID
where et.CustomerID = @CustomerID 
and l.GamingDate >= @GamingDate
and et.CancelID is null
--and et.OpTypeID = 11 --count only acquisti
order by et.[InsertTimestamp] desc

select @days = cast(VarValue as int) from [GeneralPurpose].[ConfigParams]
 where VarName = 'EuroGoldenValidityDays'

*/


return 0
GO
