SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Snoopy].[usp_GetDepositiDenominations] 
@lfid int
AS

if not exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @lfid)
begin
	select 
		denos.Denoid,
		denos.Fdescription,
		'Deposito' as SourceTag,
	        Sum(denos.Quantity) as Quantity,
		min(denos.ExchangeRate) as ExchangeRate
	from Snoopy.vw_AllDepositi dep
	inner join Snoopy.vw_AllCustomerTransactionDenominations denos
	on denos.CustomerTransactionID = dep.DepOnTransID
	where dep.DepOffTransTime is null --still have to be prelevata 
	group by 
			denos.Denoid,
			denos.Fdescription
end
else
begin
	declare @closedate datetime
	
	select @closedate = CloseTime
	from Accounting.vw_AllStockLifeCycles 
	where LifeCycleID = @lfid
	if @closedate is null
	begin
		raiserror('Lifecycleid (%d) is not closed',16,1,@lfid)
		return (2)
	end
	--print @closedate
	
	select 
		denos.Denoid,
		denos.Fdescription,
		'Deposito' as SourceTag,
	        Sum(denos.Quantity) as Quantity,
		min(denos.ExchangeRate) as ExchangeRate
	from Snoopy.vw_AllDepositi dep
	inner join Snoopy.vw_AllCustomerTransactionDenominations denos
	on denos.CustomerTransactionID = dep.DepOnTransID
	where dep.DepOnTransTime <= @CloseDate 
	and (
		dep.DepOffTransTime is null --still have to be prelevata 
		or
		dep.DepOffTransTime >= @CloseDate --prelevate today
	)
	group by 
			denos.Denoid,
			denos.Fdescription
end
GO
