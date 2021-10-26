SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE procedure [Accounting].[usp_GetDifferenzaDiCassa] 
@LifeCycleID 	int,
@gaming 	datetime out,
@LastGamingDate datetime out,
@Chiusura 	float  	 out,
@apertura 	float  	 out,
@ConsegnaPerRipristino 	 float  	 out,
@cngnXripID	int	 out,
@ripristino 	float  	 out,
@DiffCassa 	float 	 out
AS
--run some checks before doing the real job
--first make sure it is a life cycle id of a closed stock
if @LifeCycleID is null or not exists 
(
	select LifeCycleID from Accounting.tbl_LifeCycles where Accounting.tbl_LifeCycles.LifeCycleID = @LifeCycleID
)
begin
	raiserror('Invalid Life cycle id specified',16,-1)
	return (1)
end
declare @Tag varchar(32)
declare @curGaming datetime,
@EuroRate float
select @Tag = Tag , @curGaming = GamingDate from Accounting.vw_AllStockLifeCycles where LifeCycleID = @LifeCycleID

--get euro rate from exchangerates table
SELECT @EuroRate = [IntRate] FROM Accounting.tbl_CurrencyGamingdateRates
WHERE GamingDate = @curGaming AND CurrencyID = 0

print 'Stock ' + @Tag + ' Gaming date: ' + convert(varchar,@curGaming,105)
print 'euro rate: '+ cast (@EuroRate as varchar (32))
if not exists
(
	SELECT LifeCycleSnapshotID
		FROM    Accounting.tbl_Snapshots 
		WHERE   Accounting.tbl_Snapshots.SnapshotTypeID in (select SnapshotTypeID from CasinoLayout.SnapshotTypes where FName = 'Chiusura') 
		AND Accounting.tbl_Snapshots.LifeCycleID = @LifeCycleID
		--snapshot has not been cancelled
		AND Accounting.tbl_Snapshots.LCSnapShotCancelID IS NULL
)
begin
	raiserror('Life cycle %d is not closed',16,-1,@LifeCycleID)
	return (1)
end
declare @StockID int
select  @Chiusura = TotalCHF,
	@gaming = GamingDate,
	@StockID = StockID 
	from Accounting.vw_AllSnapshots 
	where LifeCycleID = @LifeCycleID and SnapshotTypeID = 3 --Chiusura
if @StockID is null
begin
	raiserror('Error getting Chiusura values',16,-1)
	return (1)
end
if @Chiusura is null
	--stock closed with 0 total values
	set @Chiusura = 0.0
--back one day
set @LastGamingDate = Accounting.fn_GetLastGamingDate(@StockID,1,DATEADD(dd,-1,@gaming))
if @LastGamingDate is not null
begin
	select @apertura = 
	SUM(Quantity * Denomination * 
	case when ValueTypeID = 7 then @EuroRate else ExchangeRate end  
	--ExchangeRate
	* WeightInTotal )      
	from Accounting.vw_AllSnapshotDenominations 
        WHERE    (StockID = @StockID ) 
	AND (GamingDate = @LastGamingDate)
	and SnapshotTypeID = 3 --Chiusura
end	
if @apertura is null
	--stock never open before
	set @apertura = 0.0

if not exists
(
	select TransactionID from Accounting.vw_AllTransactions
		where OperationName = 'ConsegnaPerRipristino' 
		and SourceLifeCycleID = @LifeCycleID
)
begin
	raiserror('No ConsegnaPerRipristino for Life cycle %d',16,-1,@LifeCycleID)
	return (1)
end


--now get preclosing value
select 	@ConsegnaPerRipristino = TotalForSource,
	@cngnXripID = TransactionID 
	from Accounting.vw_AllTransactions
	where OperationName = 'ConsegnaPerRipristino' 
	and SourceLifeCycleID = @LifeCycleID
if @cngnXripID is null
begin
	raiserror('ConsegnaPerRipristino transaction not found',16,1)
	return(1)
end
if exists 
	(
	select LifeCycleID from Accounting.vw_AllStockLifeCycles where LifeCycleID = @LifeCycleID
	and StockTypeID <> 4 and StockTypeID <> 7)
begin
	--life cycle belongs to a stock that is not a trolley or main trolley
	set @ripristino = 0
	set @DiffCassa = 0
	return
end

if not exists
(
	select TransactionID from Accounting.vw_AllTransactions
		where OperationName = 'Ripristino' and DestLifeCycleID = @LifeCycleID
)
begin
	raiserror('No ripristino for Life cycle %d',16,-1,@LifeCycleID)
	return (1)
end



if @ConsegnaPerRipristino is null 	
	--ConsegnaPerRipristino without values 
	set @ConsegnaPerRipristino = 0.0
--now get ripristino value

select 	@ripristino = TotalForDest 
	from Accounting.vw_AllTransactions
	where OperationName = 'Ripristino' and DestLifeCycleID = @LifeCycleID
if @ripristino is null
	--ripristino without values 
	set @ripristino = 0.0

print 'Stock :' + @Tag
print 'Previous Gaming date : ' + convert(varchar,@LastGamingDate,105)
print 'Apertura: ' + str(@apertura,12,2)
print 'Ripristino: ' + str(@ripristino,12,2)
print 'Chiusura: ' + str(@Chiusura,12,2)
print 'Consegna: ' + str(@ConsegnaPerRipristino,12,2)
set @DiffCassa = @Chiusura + @ConsegnaPerRipristino - @apertura - @ripristino
print 'Differenza: ' + str(@DiffCassa,12,2)
GO
GRANT EXECUTE ON  [Accounting].[usp_GetDifferenzaDiCassa] TO [SolaLetturaNoDanni]
GO
