SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [ForIncasso].[usp_GetDiffCasse]
@gaming  DATETIME
AS

/*

declare @gaming 					DATETIME

set @gaming = '7.3.2019'

--*/

DECLARE 
@ret						INT,
@LifeCycleSnapshotID		INT,
@SnapshotTimeLoc			datetime,
@OwnerName					VARCHAR(256),
@Tag						varchar(50), 
@LifeCycleID				INT,
@SnapshotTypeID				INT,
@StockID					INT


DECLARE  @lf TABLE
(								--select 
GamingDate	 		datetime,	--@gaming 					as 'GamingDate',		
LastGamingDate		datetime,	--@LastGamingDate				as 'LastGamingDate',
opTypeName			VARCHAR(50),--@opTypeName					as 'OpTypeName',
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
EuroRate			float		--@EuroRate					AS 'EuroRate'
)								

--create the cursor

set @ret = CURSOR_STATUS ('global','lf_cursor')
if @ret > -3
begin
--	print 'deallocting reg_cursor'
	DEALLOCATE lf_cursor
END

DECLARE lf_cursor CURSOR
FOR
SELECT  
	LifeCycleSnapshotID,
	SnapshotTimeLoc,
	OwnerName,
	Tag , 
	LifeCycleID ,
	SnapshotTypeID,
	StockID
from Accounting.vw_AllSnapshotsEx 
WHERE GamingDate = @gaming 
AND SnapshotTypeID = 3 --only Chiusura 
AND StockTypeID IN (4,7) --valid only for casse e CC

OPEN lf_cursor
FETCH NEXT FROM lf_cursor INTO 
@LifeCycleSnapshotID		,
@SnapshotTimeLoc			,
@OwnerName					,
@Tag						,
@LifeCycleID				,
@SnapshotTypeID				,
@StockID					

WHILE (@@FETCH_STATUS <> -1 and @LifeCycleID IS NOT null)
BEGIN

	INSERT INTO @lf
	(
		GamingDate,
		LastGamingDate,
		opTypeName,
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
		EuroRate
	)
	EXECUTE [Accounting].[usp_GetSnapshotDifferenzaDiCassa] @LifeCycleSnapshotID 

	FETCH NEXT FROM lf_cursor INTO 
		@LifeCycleSnapshotID		,
		@SnapshotTimeLoc			,
		@OwnerName					,
		@Tag						,
		@LifeCycleID				,
		@SnapshotTypeID				,
		@StockID					
END

CLOSE lf_cursor
DEALLOCATE lf_cursor



SELECT 	'CASSE_EUR_DIFFCASSA' AS ForIncassoTag,
	SUM(DiffCassaEUR) AS Amount
	FROM @lf
UNION ALL
	SELECT 	'CASSE_CHF_DIFFCASSA' AS ForIncassoTag,
	SUM(DiffCassaCHF) AS Amount
	FROM @lf
GO
