SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



CREATE FUNCTION [Accounting].[fn_GetDailyDiffCasse] (@gaming  DATETIME)
RETURNS  @lf TABLE
(								--select 
GamingDate	 		DATETIME,	--@gaming 					as 'GamingDate',		
LastGamingDate		DATETIME,	--@LastGamingDate				as 'LastGamingDate',
LifeCycleID			INT,
StockID				INT,
StockTypeID			INT,
Tag					VARCHAR(16),
OraApertura			DATETIME,
OraChiusura			DATETIME,
cngnXripID			INT,		--@cngnXripID					as 'cngnXripID',
ChiusuraSSID		INT,		--@ChiusuraSSID				as 'ChiusuraSSID',
chiusuraCHF 		FLOAT,		--@chiusuraCHF 				as 'chiusuraCHF',
aperturaCHF 		FLOAT,		--@aperturaCHF 				as 'aperturaCHF',
consegnaCHF			FLOAT,		--@consegnaCHF				as 'consegnaCHF',
ripristinoCHF		FLOAT,		--@ripristinoCHF				as 'ripristinoCHF',
DiffCassaCHF 		FLOAT,		--@DiffCassaCHF 				as 'DiffCassaCHF',
chiusuraEUR 		FLOAT,		--@chiusuraEUR 				as 'chiusuraEUR',
aperturaEUR 		FLOAT,		--@aperturaEUR 				as 'aperturaEUR',
consegnaEUR			FLOAT,		--@consegnaEUR				as 'consegnaEUR',
ripristinoEUR		FLOAT,		--@ripristinoEUR				as 'ripristinoEUR',
DiffCassaEUR 		FLOAT,		--@DiffCassaEUR 				as 'DiffCassaEUR',
EuroRate			FLOAT,		--@EuroRate					AS 'EuroRate'
DiffCassaTotCHF		FLOAT
)								
AS
BEGIN

/*

declare @gaming 					DATETIME

set @gaming = '8.1.2019'

DECLARE  @lf TABLE
(								--select 
GamingDate	 		datetime,	--@gaming 					as 'GamingDate',		
LastGamingDate		datetime,	--@LastGamingDate				as 'LastGamingDate',
StockID				INT,
StockTypeID			INT,
Tag					VARCHAR(16),
OraApertura			DATETIME,
OraChiusura			DATETIME,
cngnXripID			int,		--@cngnXripID					as 'cngnXripID',
ChiusuraSSID		INT,		--@ChiusuraSSID				as 'ChiusuraSSID',
chiusuraCHF 		float,		--@chiusuraCHF 				as 'chiusuraCHF',
aperturaCHF 		float,		--@aperturaCHF 				as 'aperturaCHF',
consegnaCHF			float,		--@consegnaCHF				as 'consegnaCHF',
ripristinoCHF		float,		--@ripristinoCHF				as 'ripristinoCHF',
DiffCassaCHF 		float,		--@DiffCassaCHF 				as 'DiffCassaCHF',
chiusuraEUR 		float,		--@chiusuraEUR 				as 'chiusuraEUR',
aperturaEUR 		float,		--@aperturaEUR 				as 'aperturaEUR',
consegnaEUR			float,		--@consegnaEUR				as 'consegnaEUR',
ripristinoEUR		float,		--@ripristinoEUR				as 'ripristinoEUR',
DiffCassaEUR 		float,		--@DiffCassaEUR 				as 'DiffCassaEUR',
EuroRate			FLOAT,		--@EuroRate					AS 'EuroRate'
DiffCassaTotCHF		FLOAT
)								

--*/

DECLARE 
@ret						INT,
@LifeCycleSnapshotID		INT




--create the cursor

set @ret = CURSOR_STATUS ('global','lf_cursor')
if @ret > -3
begin
--	print 'deallocting reg_cursor'
	DEALLOCATE lf_cursor
END

DECLARE lf_cursor CURSOR
FOR
SELECT  LifeCycleSnapshotID
from Accounting.vw_AllSnapshots 
WHERE GamingDate = @gaming 
AND SnapshotTypeID = 3 --only Chiusura 
AND StockTypeID IN (4,7) --valid only for casse e CC

OPEN lf_cursor
FETCH NEXT FROM lf_cursor INTO @LifeCycleSnapshotID

WHILE (@@FETCH_STATUS <> -1)
BEGIN

	INSERT INTO @lf
	(
	    GamingDate,
	    LastGamingDate,
		LifeCycleID,
	    StockID,
	    StockTypeID,
	    Tag,
	    OraApertura,
	    OraChiusura,
	    cngnXripID,
	    ChiusuraSSID,
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
	    EuroRate,
	    DiffCassaTotCHF
	)

/*
declare @LifeCycleSnapshotID int

set @LifeCycleSnapshotID = 378463
--*/

	SELECT  
	    GamingDate,
	    LastGamingDate,
		LifeCycleID,
	    StockID,
	    StockTypeID,
	    Tag,
	    OraApertura,
	    OraChiusura,
	    cngnXripID,
	    ChiusuraSSID,
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
	    EuroRate,
	    DiffCassaTotCHF
	FROM [Accounting].[fn_GetSnapshotDifferenzaDiCassa] (@LifeCycleSnapshotID) 

	FETCH NEXT FROM lf_cursor INTO @LifeCycleSnapshotID
END

CLOSE lf_cursor
DEALLOCATE lf_cursor

/*
SELECT * FROM @lf

SELECT 	'CASSE_EUR_DIFFCASSA' AS ForIncassoTag,
	SUM(DiffCassaEUR) AS Amount
	FROM @lf
UNION ALL
	SELECT 	'CASSE_CHF_DIFFCASSA' AS ForIncassoTag,
	SUM(DiffCassaCHF) AS Amount
	FROM @lf

*/

RETURN
END
GO
