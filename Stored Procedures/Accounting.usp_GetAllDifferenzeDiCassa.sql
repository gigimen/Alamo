SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO




CREATE PROCEDURE [Accounting].[usp_GetAllDifferenzeDiCassa] 
@gaming 					DATETIME
AS
/*

execute [Accounting].[usp_GetAllDifferenzeDiCassa] '11.29.2020'


declare @gaming 					DATETIME

set @gaming = '5.30.2019'

--*/
DECLARE 
@ret						INT,
@LifeCycleSnapshotID		INT,
@SnapshotTimeLoc			datetime,
@OwnerName					VARCHAR(256),
@OwnerID					INT,
@Tag						varchar(50), 
@LifeCycleID				INT,
@SnapshotTypeID				INT,
@StockID					INT,
@RettificaRestituzioneID	INT,
@RestituzioneID				INT,
@RestGamingDate				DATETIME

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

DECLARE  @lf2 TABLE
(
LifeCycleID	 			int,	
StockID					INT,
Tag						VARCHAR(32),
OwnerID					INT,
OwnerName				VARCHAR(256),
Ora						DATETIME,
LifeCycleSnapshotID		INT,
SnapshotTypeID			INT,
Operazione				VARCHAR(50),
chiusuraCHF 			float,	
aperturaCHF 			float,	
consegnaCHF				float,	
ripristinoCHF			float,	
DiffCassaCHF 			float,	
chiusuraEUR 			float,	
aperturaEUR 			float,	
consegnaEUR				float,	
ripristinoEUR			float,	
DiffCassaEUR 			float,	
EuroRate				FLOAT,
RettificaRestituzioneID INT,
RestituzioneID			INT,
RestGamingDate			DATETIME
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
	OwnerUserID,
	OwnerName,
	Tag , 
	LifeCycleID ,
	SnapshotTypeID,
	StockID
from Accounting.vw_AllSnapshotsEx 
WHERE GamingDate = @gaming 
AND SnapshotTypeID IN (3,4) --only Chiusura and change owner
AND StockTypeID IN (4,7) --valid only for casse e CC

OPEN lf_cursor
FETCH NEXT FROM lf_cursor INTO 
@LifeCycleSnapshotID		,
@SnapshotTimeLoc			,
@OwnerID					,
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

	SET @RettificaRestituzioneID = NULL
	SET @RestituzioneID = NULL
	SET @RestGamingDate = NULL
	--IF @SnapshotTypeID = 3 --chiusure
	--look for resituzione denaro
	IF @OwnerID IS NOT NULL
	BEGIN
		SELECT @RettificaRestituzioneID = [PK_RettificaRestituzioneID] 
		FROM [Accounting].[tbl_Rettifica_Restituzione]
		WHERE [FK_StockID] = @StockID AND [GamingDate] = @gaming AND [FK_RespID] = @OwnerID

		IF @RettificaRestituzioneID IS NOT NULL
			SELECT @RestituzioneID = [PK_RestituzioneID],@RestGamingDate = RestGamingDate
			FROM Snoopy.tbl_CustomerRestituzioni 
			WHERE [FK_RettificaRestituzioneID] = @RettificaRestituzioneID
    END

	INSERT into @lf2 
	(
		LifeCycleID	 		,
		StockID				,
		Tag					,
		OwnerID				,
		OwnerName			,
		Ora					,
		LifeCycleSnapshotID	,
		SnapshotTypeID		,
		Operazione			,
		chiusuraCHF 		,
		aperturaCHF 		,
		consegnaCHF			,
		ripristinoCHF		,
		DiffCassaCHF 		,
		chiusuraEUR 		,
		aperturaEUR 		,
		consegnaEUR			,
		ripristinoEUR		,
		DiffCassaEUR 		,
		EuroRate			,
		RettificaRestituzioneID,
		RestituzioneID		,
		RestGamingDate
	)
	SELECT 
		@LifeCycleID,
		@StockID,
		@Tag,
		@OwnerID,
		@OwnerName,
		@SnapshotTimeLoc,
		@LifeCycleSnapshotID,
		@SnapshotTypeID,
		opTypeName,
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
		@RettificaRestituzioneID,
		@RestituzioneID,
		@RestGamingDate
	FROM @lf 

	DELETE FROM  @lf

	FETCH NEXT FROM lf_cursor INTO 
		@LifeCycleSnapshotID		,
		@SnapshotTimeLoc			,
		@OwnerID					,
		@OwnerName					,
		@Tag						,
		@LifeCycleID				,
		@SnapshotTypeID				,
		@StockID					
END

CLOSE lf_cursor
DEALLOCATE lf_cursor



--SELECT * FROM @lf2 ORDER BY StockID, Ora


SELECT 
	@gaming AS GamingDate,
	c.Tag,
	c.StockID,
	c.LifeCycleID,
	c.Operazione,
	c.SnapshotTypeID,
	c.LifeCycleSnapshotID,
	c.Ora,
	c.OwnerID,
	c.Responsabile,
	c.AperturaCHF,
	c.RisultatoCHF,
	c.DiffCassaCHF,
	c.AperturaEUR,
	c.RisultatoEUR,
	c.DiffCassaEUR,
	c.EuroRate,
	rett.EURCents		AS RettificaEURCents,
	rett.CHFCents		AS RettificaCHFCents,
	rett.Nota,
	cc.GamingDate		AS CCGamingDate,
	c.DiffCassaCHF + c.DiffCassaEUR * c.EuroRate AS DiffCassaTotCHF,
	c.RettificaRestituzioneID,
	c.RestituzioneID,
	c.RestGamingDate
FROM
(
	SELECT 
	a.Tag,
	a.StockID,
	a.LifeCycleID,
	a.Operazione,
	a.SnapshotTypeID,
	a.LifeCycleSnapshotID,
	a.Ora,
	a.OwnerID,
	a.OwnerName AS Responsabile,
	a.aperturaCHF + a.ripristinoCHF AS AperturaCHF,
	a.chiusuraCHF + a.consegnaCHF AS RisultatoCHF,
	a.DiffCassaCHF,
	a.aperturaEUR + a.ripristinoEUR AS AperturaEUR,
	a.chiusuraEUR + a.consegnaEUR AS RisultatoEUR,
	a.DiffCassaEUR,
	a.EuroRate,
	a.RettificaRestituzioneID,
	a.RestituzioneID,
	a.RestGamingDate
	FROM @lf2 a
) c
LEFT OUTER JOIN [Accounting].[tbl_Rettifiche] rett ON rett.FK_LifeCycleSnapshotID = c.LifeCycleSnapshotID
LEFT OUTER JOIN [Accounting].[vw_AllStockLifeCycles] cc ON rett.FK_LifeCycleID = cc.LifeCycleID

ORDER BY c.StockID,c.Ora
GO
