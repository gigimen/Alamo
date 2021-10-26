SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



CREATE FUNCTION [Accounting].[fn_GetDiffCasse] (@fromdate  DATETIME,@todate datetime)
RETURNS  @dc TABLE
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
RettCassaCHF		FLOAT,
chiusuraEUR 		FLOAT,		--@chiusuraEUR 				as 'chiusuraEUR',
aperturaEUR 		FLOAT,		--@aperturaEUR 				as 'aperturaEUR',
consegnaEUR			FLOAT,		--@consegnaEUR				as 'consegnaEUR',
ripristinoEUR		FLOAT,		--@ripristinoEUR				as 'ripristinoEUR',
DiffCassaEUR 		FLOAT,		--@DiffCassaEUR 				as 'DiffCassaEUR',
RettCassaEUR		FLOAT,
EuroRate			FLOAT,		--@EuroRate					AS 'EuroRate'
DiffCassaTotCHF		FLOAT,
RettCassaTotCHF		FLOAT,
[Nota]				VARCHAR(256)
)								
AS
BEGIN

/*

select * from [Accounting].[fn_GetDiffCasse] ('1.1.2020','9.30.2020')

*/
	DECLARE @gaming DATETIME


	SET @gaming = @fromdate

	WHILE @gaming <= @todate
	BEGIN

		INSERT INTO @dc
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
		    RettCassaCHF,
		    chiusuraEUR,
		    aperturaEUR,
		    consegnaEUR,
		    ripristinoEUR,
		    DiffCassaEUR,
		    RettCassaEUR,
		    EuroRate,
		    DiffCassaTotCHF,
		    RettCassaTotCHF,
			[Nota]
		)
		SELECT 
		    d.GamingDate,
		    d.LastGamingDate,
		    d.LifeCycleID,
		    d.StockID,
		    d.StockTypeID,
		    d.Tag,
		    d.OraApertura,
		    d.OraChiusura,
		    d.cngnXripID,
		    d.ChiusuraSSID,
		    d.chiusuraCHF,
		    d.aperturaCHF,
		    d.consegnaCHF,
		    d.ripristinoCHF,
		    d.DiffCassaCHF,
		    CAST(ISNULL(r.CHFCents,0) AS float) / 100.0 AS RettCassaCHF,
		    d.chiusuraEUR,
		    d.aperturaEUR,
		    d.consegnaEUR,
		    d.ripristinoEUR,
		    d.DiffCassaEUR,
		    CAST(ISNULL(r.EURCents,0) AS FLOAT) / 100.0 AS RettCassaEUR,
		    d.EuroRate,
		    d.DiffCassaTotCHF,
		    CAST(ISNULL(r.CHFCents,0) AS float) / 100.0  + (CAST(ISNULL(r.EURCents,0) AS FLOAT) / 100.0 * d.EuroRate) AS RettCassaTotCHF,
			r.Nota
		FROM Accounting.fn_GetDailyDiffCasse(@gaming) d
		LEFT outer JOIN  Accounting.tbl_Rettifiche r ON r.FK_LifeCycleSnapshotID = d.ChiusuraSSID

		SET @gaming = DATEADD(DAY,1,@gaming)
	END
RETURN
END
GO
