SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetSnapshotDifferenzaDiCassa] 
@LifeCycleSnapshotID 				INT
AS
/*
example: 
execute  [Accounting].[usp_GetSnapshotDifferenzaDiCassa] 374535 374570
*/
DECLARE
@LifeCycleID				INT,
@gaming 					DATETIME,
@LastGamingDate				DATETIME,
@ChiusuraSSID				INT		,
@chiusuraCHF 				FLOAT  	,
@aperturaCHF 				FLOAT  	,
@consegnaCHF				FLOAT  	,
@ripristinoCHF				FLOAT  	,
@DiffCassaCHF 				FLOAT 	,
@chiusuraEUR 				FLOAT  	,
@aperturaEUR 				FLOAT  	,
@consegnaEUR				FLOAT  	,
@ripristinoEUR				FLOAT  	,
@DiffCassaEUR 				FLOAT 	,
@Tag						varchar(32),
@curGaming					DATETIME,
@EuroRate					FLOAT,
@cngnXripID					INT,
@StockID					INT,
@SnapshotTypeID				INT ,
@opTypeName					varchar(50)
--run some checks before doing the real job
--first make sure it is a life cycle id of a closed stock
SELECT  
	@opTypeName = FName,
	@Tag = Tag , 
	@curGaming = GamingDate,
	@LifeCycleID = LifeCycleID ,
	@SnapshotTypeID = SnapshotTypeID,
	@chiusuraCHF = TotalCHF,
	@chiusuraEUR = TotalEUR,
	@gaming = GamingDate,
	@StockID = StockID
from Accounting.vw_AllSnapshotsEx 
WHERE LifeCycleSnapshotID = @LifeCycleSnapshotID
AND SnapshotTypeID IN (2,3,4) --only Chiusura,midway and change owner
AND StockTypeID IN (4,7) --valid only for casse e CC

if @LifeCycleID is null 
begin
	raiserror('Invalid Lifecycle snapshotid (%d) specified',16,-1,@LifeCycleSnapshotID)
	RETURN (1)
END

--get euro rate from exchangerates table
SELECT @EuroRate = [IntRate] FROM Accounting.tbl_CurrencyGamingdateRates
WHERE GamingDate = @curGaming AND CurrencyID = 0

--print 'Stock ' + @Tag + ' Gaming date: ' + convert(varchar,@curGaming,105)
--print 'euro rate: '+ cast (@EuroRate as varchar (32))


IF @chiusuraCHF is null
	--stock closed with 0 total values
	set @chiusuraCHF = 0.0
if @chiusuraEUR is null
	--stock closed with 0 total values
	set @chiusuraEUR = 0.0

--back one day
set @LastGamingDate = Accounting.fn_GetLastGamingDate(@StockID,1,DATEADD(dd,-1,@gaming))
if @LastGamingDate is not null
begin
	select 
		@aperturaCHF = TotalCHF,
		@aperturaEUR = TotalEUR
	from Accounting.vw_AllSnapshotsEx 
        WHERE    (StockID = @StockID ) 
	AND (GamingDate = @LastGamingDate)
	and SnapshotTypeID = 3 --Chiusura
end	
if @aperturaCHF is null
	--stock never open before
	set @aperturaCHF = 0.0
if @aperturaEUR is null
	--stock never open before
	set @aperturaEUR = 0.0

IF @SnapshotTypeID = 3
BEGIN

	select @cngnXripID = TransactionID from Accounting.vw_AllTransactions
	where OpTypeID = 6 --'ConsegnaPerRipristino' 
	and SourceLifeCycleID = @LifeCycleID
	if @cngnXripID = null
	begin
		raiserror('No ConsegnaPerRipristino for Life cycle %d',16,-1,@LifeCycleID)
		RETURN (1)
	END


	--now get Consegna value
	select 	@consegnaCHF = TotalCHFForSource,
			@consegnaEUR = TotalEURForSource
	from Accounting.vw_AllTransactionsEx
	where @cngnXripID = TransactionID 

END

if @consegnaCHF is null
	set @consegnaCHF = 0.0
if @consegnaEUR is null
	set @consegnaEUR = 0.0

IF NOT EXISTS
(
	SELECT TransactionID FROM Accounting.vw_AllTransactions
	WHERE OpTypeID = 5 --'Ripristino' 
	AND DestLifeCycleID = @LifeCycleID
)
BEGIN
	RAISERROR('No ripristino for Life cycle %d',16,-1,@LifeCycleID)
	RETURN (1)
END




--now get ripristino value

SELECT 	
@ripristinoCHF = TotalCHFForDest, 
@ripristinoEUR = TotalEURForDest 
FROM Accounting.vw_AllTransactionsEx
WHERE OpTypeID = 5 --'Ripristino' 
AND DestLifeCycleID = @LifeCycleID

IF @ripristinoCHF IS NULL
	--ripristino without values 
	SET @ripristinoCHF = 0.0
IF @ripristinoEUR IS NULL
	--ripristino without values 
	SET @ripristinoEUR = 0.0

PRINT 'Stock :' + @Tag
PRINT 'Previous Gaming date : ' + CONVERT(VARCHAR,@LastGamingDate,105)
PRINT '
-----------------CHF---------------------'
PRINT 'AperturaCHF	: ' + STR(@aperturaCHF,12,2)
PRINT 'RipristinoCHF: ' + STR(@ripristinoCHF,12,2)
PRINT 'ChiusuraCHF  : ' + STR(@chiusuraCHF,12,2)
PRINT 'ConsegnaCHF	: ' + STR(@ConsegnaCHF,12,2)
SET @DiffCassaCHF = @chiusuraCHF + @ConsegnaCHF - @aperturaCHF - @ripristinoCHF
PRINT 'DifferenzaCHF: ' + STR(@DiffCassaCHF,12,2)
PRINT '
-----------------EUR---------------------'
PRINT 'AperturaEUR	: ' + STR(@aperturaEUR,12,2)
PRINT 'RipristinoEUR: ' + STR(@ripristinoEUR,12,2)
PRINT 'ChiusuraEUR  : ' + STR(@chiusuraEUR,12,2)
PRINT 'ConsegnaEUR	: ' + STR(@ConsegnaEUR,12,2)
SET @DiffCassaEUR = @chiusuraEUR + @ConsegnaEUR - @aperturaEUR - @ripristinoEUR
PRINT 'DifferenzaEUR: ' + STR(@DiffCassaEUR,12,2)


select 
@gaming 					as 'GamingDate',
@LastGamingDate				as 'LastGamingDate',
@opTypeName					as 'OpTypeName',
@cngnXripID					as 'cngnXripID',
@ChiusuraSSID				as 'ChiusuraSSID',
@chiusuraCHF 				as 'chiusuraCHF',
@aperturaCHF 				as 'aperturaCHF',
@consegnaCHF				as 'consegnaCHF',
@ripristinoCHF				as 'ripristinoCHF',
@DiffCassaCHF 				as 'DiffCassaCHF',
@chiusuraEUR 				as 'chiusuraEUR',
@aperturaEUR 				as 'aperturaEUR',
@consegnaEUR				as 'consegnaEUR',
@ripristinoEUR				as 'ripristinoEUR',
@DiffCassaEUR 				as 'DiffCassaEUR',
@EuroRate					AS 'EuroRate'
GO
GRANT EXECUTE ON  [Accounting].[usp_GetSnapshotDifferenzaDiCassa] TO [SolaLetturaNoDanni]
GO
