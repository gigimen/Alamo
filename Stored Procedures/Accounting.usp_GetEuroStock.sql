SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetEuroStock]
@LifeCycleID INT,
@TotEuro FLOAT OUTPUT,
@CountEuro INT OUTPUT,
@UtileCambio FLOAT OUT,
@CommissioniCC FLOAT OUT
AS


declare @rip float,
@precCh float,
@received float,
@given float,
@IntRate FLOAT,
@LastGamingDate DATETIME,
@StockID INT,
@gaming DATETIME

--check input value
select 
	@StockID = StockID,
	@gaming = GamingDate 
FROM Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID


if @StockID is null
begin
	raiserror('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
	RETURN 1
END

--first get euro present in Chiusura of previuos GamingDate

set @LastGamingDate = Accounting.fn_GetLastGamingDate(@StockID,1,DATEADD(dd,-1,@gaming))
if @LastGamingDate is not null
begin
	select @precCh = SUM(Quantity * Denomination)      
	from Accounting.vw_AllSnapshotDenominations 
        WHERE    (StockID = @StockID ) 
	AND (GamingDate = @LastGamingDate)
	and SnapshotTypeID = 3 --Chiusura
	and ValueTypeID in (7,40) --euro banconote e monete
end	
if @precCh is null
	--stock never open before
	set @precCh = 0.0
print 'Prev Chiusura GamingDate '  + convert(varchar(32),@LastGamingDate,113)
print 'Prev Chiusura '  + cast(@precCh as varchar(32))

--then get euro present in ripristino
select 
	@rip = isnull(sum(Quantity*Denomination),0.0)
from Accounting.vw_AllTransactionDenominations
where DestLifeCycleID = @LifeCycleID
and ValueTypeID in (7,40) --euro banconote e monete
and OpTypeID = 5 -- ripristino
print 'Ripristino '  + cast(@rip as varchar(32))

--sum all acconti
select @received = isnull(sum(Quantity*Denomination),0) 
FROM Accounting.vw_AllTransactionDenominations
where 
(
	--i am the source of an account
	SourceLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 1 --accont
	and DestLifeCycleID is not null --count only not pending transactions
) 
or
(
	--I am the destination of a versamento
	DestLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 4 --versamenti
)
print 'Received '  + cast(@received as varchar(32))


--sum all versamenti
select @given = isnull(sum(Quantity*Denomination),0) 
from
Accounting.vw_AllTransactionDenominations
where 
(
	--i am the source of a versamento
	SourceLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 4 --versamenti
	and DestLifeCycleID is not null --count only not pending transactions
)or
(
	--i am the destiantion of an acconto
	DestLifeCycleID = @LifeCycleID
	and ValueTypeID in (7,40) --euro banconote e monete
	and OpTypeID = 1 --accont
)
print 'Given '  + cast(@given as varchar(32))

--add all acquisti
declare @acquisti float
declare @redemptions float
select @acquisti = isnull(sum(cast(ImportoEuroCents as float) / 100 ),0.0),
	@CountEuro = isnull(count(*),0)
from Accounting.tbl_EuroTransactions
where LifeCycleID = @LifeCycleID 
and OpTypeID = 11 -- it is an acquisto
and CancelID is null
and PhysicalEuros = 1 --count only physical euros don't count transaction with ecash or credit cards
print 'Acquisti '  + cast(@acquisti as varchar(32))


select @redemptions = isnull(sum(cast(ImportoEuroCents as float) / 100 ),0.0),
	@CountEuro = @CountEuro + isnull(count(*),0)
from Accounting.tbl_EuroTransactions
where LifeCycleID = @LifeCycleID 
and (OpTypeID = 12  or OpTypeID = 13 ) -- it is a redemption or a vendita
and PhysicalEuros = 1 --count only physical euros don't count transaction with ecash or credit cards
and CancelID is null
print 'Redemptions + Vendite '  + cast(@redemptions as varchar(32))


set @TotEuro = @rip + @precCh + @received - @given + @acquisti - @redemptions


SELECT  @IntRate = IntRate 
FROM Accounting.tbl_CurrencyGamingdateRates e
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.GamingDate = e.GamingDate
WHERE lf.LifeCycleID = @LifeCycleID AND e.CurrencyID = 0

SELECT @UtileCambio = ISNULL(SUM(CAST(ImportoEuroCents AS FLOAT) / 100 *(ExchangeRate - @IntRate)),0)
FROM Accounting.tbl_EuroTransactions
WHERE LifeCycleID = @LifeCycleID 
AND OpTypeID = 13 -- it is a vendita
AND PhysicalEuros = 1 --count only physical euros don't count transaction with ecash or credit cards
AND CancelID IS NULL

PRINT 'UtileCambio '  + CAST(@UtileCambio AS VARCHAR(32))

--we have to add to utile cambio also all commissioni aduno in sfr

SELECT @CommissioniCC = ISNULL(SUM([CommisioneInSfr]),0)
  FROM [Accounting].[vw_AllCartediCredito]
WHERE LifeCycleID = @LifeCycleID

--in case of main cassa add also commisioni assegni
IF EXISTS (SELECT StockID FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @LifeCycleID AND StockID = 46)
BEGIN
	SELECT  @CommissioniCC += ISNULL(SUM(CommissioneCHF),0)
	FROM [Snoopy].[vw_AllAssegni]
	WHERE GamingDate IN ( SELECT GamingDate FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @LifeCycleID )
	AND CentaxCode <> 'NG'
	AND CentaxCode <> 'NG-C'
	AND RedemCustTransID IS NULL
	--LM:dal 3.5.2016 applichiamo la commissione anche agli assegni per crediti sfr
--	AND PrelievoEuro = 1
END

/*
select Quantity,ExchangeRate,@IntRate
from Accounting.EuroTransactions
where LifeCycleID = @LifeCycleID 
and OpTypeID = 13 -- it is a vendita
and CancelID is null


select  @UtileCambio = @UtileCambio * (SellingRate - IntRate )
from tbl_CurrencyGamingdateRates e
inner join Accounting.tbl_LifeCycles lf on lf.GamingDate = e.GamingDate
where lf.LifeCycleID = @LifeCycleID and e.CurrencyID = 0
print 'UtileCambio '  + cast(@UtileCambio as varchar(32))
*/
RETURN 0
GO
