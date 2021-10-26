SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO





CREATE FUNCTION [Accounting].[fn_GetSnapshotDifferenzaDiCassa] (@LifeCycleSnapshotID 				INT)

RETURNS @r TABLE (
LifeCycleID				INT		,
StockID					INT,
StockTypeID				INT,
GamingDate				DATETIME,
LastGamingDate			DATETIME,
ChiusuraSSID			INT		,
OraApertura				DATETIME,
OraChiusura				DATETIME,
chiusuraCHF 			FLOAT  	,
aperturaCHF 			FLOAT  	,
consegnaCHF				FLOAT  	,
ripristinoCHF			FLOAT  	,
DiffCassaCHF 			FLOAT 	,
chiusuraEUR 			FLOAT  	,
aperturaEUR 			FLOAT  	,
consegnaEUR				FLOAT  	,
ripristinoEUR			FLOAT  	,
DiffCassaEUR 			FLOAT 	,
DiffCassaTotCHF			FLOAT	,
Tag						VARCHAR(32),
curGaming				DATETIME,
EuroRate				FLOAT,
cngnXripID				INT,
SnapshotTypeID			INT ,
opTypeName				VARCHAR(50)
)
AS
BEGIN
/*
example: 
select * from  [Accounting].[fn_GetSnapshotDifferenzaDiCassa] (374535)
*/

DECLARE
@LifeCycleID				INT,
@GamingDate					DATETIME,
@LastGamingDate				DATETIME,
@OraApertura				DATETIME,
@OraChiusura				DATETIME,
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
@StockTypeID				INT,
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
	@GamingDate = GamingDate,
	@StockID = StockID,
	@StockTypeID = StockTypeID

from Accounting.vw_AllSnapshotsEx 
WHERE LifeCycleSnapshotID = @LifeCycleSnapshotID
AND SnapshotTypeID IN (2,3,4) --only Chiusura,midway and change owner
AND StockTypeID IN (4,7) --valid only for casse e CC

if @LifeCycleID is null 
begin
	RETURN
END

--get euro rate from exchangerates table
SELECT @EuroRate = [IntRate] FROM Accounting.tbl_CurrencyGamingdateRates
WHERE GamingDate = @curGaming AND CurrencyID = 0
if @EuroRate is null 
begin
	RETURN
END

--print 'Stock ' + @Tag + ' Gaming date: ' + convert(varchar,@curGaming,105)
--print 'euro rate: '+ cast (@EuroRate as varchar (32))


IF @chiusuraCHF is null
	--stock closed with 0 total values
	set @chiusuraCHF = 0.0
if @chiusuraEUR is null
	--stock closed with 0 total values
	set @chiusuraEUR = 0.0

--back one day
set @LastGamingDate = Accounting.fn_GetLastGamingDate(@StockID,1,DATEADD(dd,-1,@GamingDate))
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

--get ora apertura from apertura snapshot
SELECT @OraApertura  = SnapshotTimeLoc from Accounting.vw_AllSnapshotsEx 
    WHERE    (StockID = @StockID ) 
AND (GamingDate = @GamingDate)
and SnapshotTypeID = 1 --apertura

if @aperturaCHF is null
	--stock never open before
	set @aperturaCHF = 0.0
if @aperturaEUR is null
	--stock never open before
	set @aperturaEUR = 0.0

IF @SnapshotTypeID = 3 --in case of Chiusura
BEGIN

	select 
		@cngnXripID = TransactionID
	FROM Accounting.vw_AllTransactions
	where OpTypeID = 6 --'ConsegnaPerRipristino' 
	and SourceLifeCycleID = @LifeCycleID

	IF @cngnXripID IS NOT NULL
		--now get Consegna value
		SELECT 	@consegnaCHF = TotalCHFForSource,
				@consegnaEUR = TotalEURForSource
		FROM Accounting.vw_AllTransactionsEx
		WHERE @cngnXripID = TransactionID 

END

if @consegnaCHF is null
	set @consegnaCHF = 0.0
if @consegnaEUR is null
	set @consegnaEUR = 0.0

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


SET @DiffCassaCHF = @chiusuraCHF + @ConsegnaCHF - @aperturaCHF - @ripristinoCHF
SET @DiffCassaEUR = @chiusuraEUR + @ConsegnaEUR - @aperturaEUR - @ripristinoEUR


IF @SnapshotTypeID = 3 --in case of Chiusura
	SELECT @ChiusuraSSID = LifeCycleSnapshotID,
		@OraChiusura = SnapshotTimeLoc 
	FROM Accounting.vw_AllSnapshotsEx 
	WHERE 	 LifeCycleSnapshotID = @LifeCycleSnapshotID
ELSE
	SELECT @ChiusuraSSID = SnapshotTypeID
	FROM Accounting.vw_AllSnapshotsEx 
	WHERE 	@LifeCycleID = LifeCycleID AND SnapshotTypeID = 3

/*
PRINT 'Stock :' + @Tag
PRINT 'Previous Gaming date : ' + CONVERT(VARCHAR,@LastGamingDate,105)
PRINT '
-----------------CHF---------------------'
PRINT 'AperturaCHF	: ' + STR(@aperturaCHF,12,2)
PRINT 'RipristinoCHF: ' + STR(@ripristinoCHF,12,2)
PRINT 'ChiusuraCHF  : ' + STR(@chiusuraCHF,12,2)
PRINT 'ConsegnaCHF	: ' + STR(@ConsegnaCHF,12,2)
PRINT 'DifferenzaCHF: ' + STR(@DiffCassaCHF,12,2)
PRINT '
-----------------EUR---------------------'
PRINT 'AperturaEUR	: ' + STR(@aperturaEUR,12,2)
PRINT 'RipristinoEUR: ' + STR(@ripristinoEUR,12,2)
PRINT 'ChiusuraEUR  : ' + STR(@chiusuraEUR,12,2)
PRINT 'ConsegnaEUR	: ' + STR(@ConsegnaEUR,12,2)
PRINT 'DifferenzaEUR: ' + STR(@DiffCassaEUR,12,2)
*/

INSERT INTO @r
(
    LifeCycleID,
    StockID,
    StockTypeID,
    GamingDate,
    LastGamingDate,
    ChiusuraSSID,
    OraApertura,
    OraChiusura,
    chiusuraCHF,
    aperturaCHF,
    consegnaCHF,
    ripristinoCHF,
    DiffCassaCHF,
    chiusuraEUR,
    aperturaEUR,
    consegnaEUR,
    ripristinoEUR,
    DiffCassaEUR,
    DiffCassaTotCHF,
    Tag,
    curGaming,
    EuroRate,
    cngnXripID,
    SnapshotTypeID,
    opTypeName
)
SELECT 
    @LifeCycleID,
    @StockID,
    @StockTypeID,
    @GamingDate,
    @LastGamingDate,
    @ChiusuraSSID,
    @OraApertura,
    @OraChiusura,
    @chiusuraCHF,
    @aperturaCHF,
    @consegnaCHF,
    @ripristinoCHF,
    @DiffCassaCHF,
    @chiusuraEUR,
    @aperturaEUR,
    @consegnaEUR,
    @ripristinoEUR,
    @DiffCassaEUR,
    @DiffCassaCHF + @DiffCassaEUR * @EuroRate AS DiffCassaTotCHF,
    @Tag,
    @curGaming,
    @EuroRate,
    @cngnXripID,
    @SnapshotTypeID,
    @opTypeName

RETURN
END
GO
