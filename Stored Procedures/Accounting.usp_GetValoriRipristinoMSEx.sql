SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_GetValoriRipristinoMSEx] 
@LFID int,
@TotTavoli float output,
@TotTrolleys float output
AS

declare @TotConsNonFisico float
--check that this is the LifeCycle of the Main Stock
if not exists 
	(select LifeCycleID from Accounting.tbl_LifeCycles inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
		where LifeCycleID = @LFID 
		and CasinoLayout.Stocks.StockTypeID = 2 --'Main Stocks')
	) 
begin
	raiserror('The LifeCycle %d is not of a Main Stock',16,1,@LFID)
	return(1)
end
declare @gaming datetime
select @gaming = GamingDate from Accounting.tbl_LifeCycles where LifeCycleID = @LFID

--make sure that all trolleys and main trolleys are closed for that gaming date
if exists(
	select LifeCycleID from Accounting.vw_AllStockLifeCycles
		where GamingDate = @gaming 
	 	and CloseTime is null
	 	and StockTypeID in (4,7) -- 'Trolleys' or 'Main Trolleys')
	)
begin
	declare @tmp varchar(128)
	set @tmp = 'Some trolley is still open for gaming date ' + convert(varchar(16),@gaming)
	raiserror(@tmp,16,1)
	return (1)
end


--check if we forgot some Denomination to be handled by Main Stock
declare @DenoID int
SELECT @DenoID = tv.DenoID
FROM    Accounting.tbl_Transactions t
inner join Accounting.tbl_LifeCycles l on l.LifeCycleID = t.SourceLifeCycleID
inner join CasinoLayout.Stocks s on s.StockID = l.StockID
left outer join Accounting.tbl_TransactionValues tv on tv.TransactionID = t.TransactionID
left outer join CasinoLayout.tbl_Denominations d on tv.DenoID = d.DenoID
where s.StockTypeID in (4,7) --Trolleys or Main Trolleys
	and t.OpTypeID = 6 --ConsegnaPerRipristino
	and t.DestLifeCycleID = @LFID
	--and DestUserGroupID = 13 --Incasso Managers
	and d.ValueTypeID not in 
			(1,-- 'Banconote'
				2,--'Monete'
				3,--'Gettoni sfr'
				7,--'Euro'
				36, --'gettoni euro'
				12, --'Transazioni Cassa'
				14-- 'Transazioni Main Stock'
		)
	and tv.DenoID not in
	(select DenoID
	from Accounting.vw_AllLifeCycleDenominations
	where LifeCycleID = @LFID 	
	)
if @DenoID is not null
begin
	raiserror('Deno %d unhandled by MainStock',16,1,@DenoID)
	return (1)
end




--Get all non fisico values ConsegnXRip received from trolleys by this lifecycle
SELECT  @TotConsNonFisico = SUM(Quantity * Denomination * ExchangeRate * WeightForDest)
FROM    Accounting.vw_AllTransactionDenominations
where SourceStockTypeID in (4,7) --Trolleys or Main Trolleys
	and OpTypeID = 6 --ConsegnaPerRipristino
	and DestLifeCycleID = @LFID
	AND	CurrencyID  <> 0 --everything but euros
	and ValueTypeID not in 
			(1,-- 'Banconote'
				2,--'Monete'
				3,--'Gettoni'
				7,--'Euro'
				36, --'gettoni euro'
				12, --'Transazioni Cassa'
				14-- 'Transazioni Main Stock'
		)
print @gaming
if @TotConsNonFisico is null
begin
	print 'Totale non fisico consegnato al MS è nullo'
	set @TotConsNonFisico = 0
end
else
begin
	print 'Totale non fisico consegnato al MS: ' + STR(@TotConsNonFisico,12,2)
end

declare @TotDiffCassa float
SELECT @TotDiffCassa = SUM(Isnull(DiffCassa,0)) 
FROM Accounting.vw_AllStockDiffCassaEx
Where GamingDate = @gaming AND CurrencyID = 4 --only chf

print 'Totale diff cassa ' + str(@TotDiffCassa,12,2)


set @TotTrolleys = @TotConsNonFisico - @TotDiffCassa
print 'Totale da ripristinare parte trolley ' + str(@TotTrolleys,12,2)


--we also have to ripristinate what main stock receives from tables
declare @consTavoli float


select @consTavoli = sum(IsNull(Consegna,0)) 
from Accounting.vw_AllConsegnaRipristiniTavoli
where GamingDate = @gaming
print 'Totale consegnato dai tavoli ' + str(IsNull(@consTavoli,0),12,2)


declare @ripTavoli float
select @ripTavoli = sum(IsNull(Ripristino,0)) 
from Accounting.vw_AllConsegnaRipristiniTavoli
where GamingDate = @gaming
print 'Totale Ripristinato ai tavoli ' + str(IsNull(@ripTavoli,0),12,2)

set @TotTavoli = IsNull(@ripTavoli,0) - IsNull(@consTavoli,0)
print 'Totale da ripristinare parte tavoli ' + str(@TotTavoli,12,2)
GO
