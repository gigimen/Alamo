SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [Accounting].[usp_GetAllStocksConteggi] 
@ssTypeID		INT,
@gaming			DATETIME,
@EuroRate		FLOAT OUTPUT,
@totstocks		INT OUTPUT--,@isMSOpen		BIT OUTPUT
AS


if @gaming is null or @gaming = null
BEGIN
	--we always have to specify the gaming date 
	--otherwise we have troubles getting the previous close gaming date
	RAISERROR('Specify a valid Gaming Date',16,1)
	RETURN (1)
END
IF @ssTypeID IN(12,--conteggio ecash
13 --conteggi MET
)
BEGIN
	RAISERROR('Questo tipo di conteggionon è piú supportato!',16,1)
	RETURN (1)
END

/*
IF EXISTS(
	SELECT [LifeCycleID] 
	FROM [Accounting].[vw_AllStockLifeCycles]
	WHERE [StockTypeID] = 2 --MS
	AND GamingDate = @gaming --current GamingDate
	AND OpenTime IS NOT NULL --opened
	AND CloseSnapshotID IS NULL --not closed
)
	SET @isMSOpen = 1
ELSE
	SET @isMSOpen = 0
	*/
select @EuroRate = IntRate from [Accounting].tbl_CurrencyGamingdateRates
where CurrencyID = 0 
AND GamingDate = @gaming

IF @ssTypeID IN(--6,7,8,9,10,11,14,15,18,19,22,23,24,25)  --conteggi tavoli e conteggi tronc tavoli

6	,--Conteggio Uscita	Conteggio in uscita dal MainStock
7	,--Conteggio Box tavoli	Conteggio dei box dei tavoli
8	,--Conteggio Tronc Tavoli	NULL
9	,--Conteggio Tronc	NULL
10	,--Conteggio Gastro	NULL
11	,--Conteggio Bancomat	NULL
--12	,--Conteggio ECash	NULL
--13	,--Conteggio MET	NULL
14	,--Conteggio Box Sorveglianza	NULL
15	,--Conteggio Tronc Sorveglianza	NULL
--17	,--Movimento dotazione gettoni	Acquisto/eliminazione gettoni per LG
18	,--Conteggio KioskCHF	NULL
19	,--Conteggio KioskEUR	NULL
--20	,--Conteggio Tronc Gastro	NULL
--21	,--VenditaTichange	NULL
22	,--Conteggio Box Poker	NULL
23	,--Conteggio Tronc Poker	NULL
24	,--Conteggio Box Poker Sorveglianza	NULL
25	--Conteggio Tronc Poker Sorveglianza	NULL
)
BEGIN
	--count them and return it
	select @totstocks = count(StockID) from CasinoLayout.Stocks s
	where s.StockTypeID = (select ForStockTypeID	from [CasinoLayout].[SnapshotTypes] where SnapshotTypeID = @ssTypeID)
		and  @gaming >= s.FromGamingDate 
		AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS null) 
		AND s.StockID <> 85 --nascondi Gastro dal conteggio della Gastro (solo Bar e Ristorante)
	SELECT
		s.Tag
		,s.StockTypeID
		,s.StockID
		,cont.ConteggioID
		,cont.[DenoID]
		,cont.[DenoName]
		,cont.[ValueTypeName]
		,cont.CurrencyAcronim
		,cont.[Denomination]
		,cont.[Quantity]
		,cont.[ExchangeRate]
		,cont.[ValueSfr]
		,cont.[ConteggioTimeUTC]
		,cont.[ConteggioTimeLoc]
	FROM CasinoLayout.Stocks s
	LEFT OUTER JOIN 
	(
			SELECT 
			  c.ConteggioID
			, c.[StockID]
			, c.[Tag]
			, c.[DenoID]
			, c.[DenoName]
			, c.[ValueTypeName]
			, c.CurrencyAcronim
			, c.[Quantity]
			, c.[Denomination]
			, c.[ExchangeRate]
			, c.[ValueSfr]
			, c.[ConteggioTimeUTC]
			, c.[ConteggioTimeLoc]
			FROM [Accounting].[vw_AllConteggiDenominations] c 
			WHERE [GamingDate] = @gaming AND SnapshotTypeID = @ssTypeID
	) cont ON cont.StockID = s.StockID
	WHERE s.StockTypeID = (SELECT ForStockTypeID	FROM [CasinoLayout].[SnapshotTypes] WHERE SnapshotTypeID = @ssTypeID)
		AND  @gaming >= s.FromGamingDate 
		AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS NULL) 
		AND s.StockID <> 85 --nascondi Gastro dal conteggio della Gastro (solo Bar e Ristorante)
		
	ORDER BY  s.StockID
END
ELSE 

BEGIN
	RAISERROR('Tipo di conteggio (%d) ancora da implementare',16,1,@ssTypeID)
	RETURN (1)
END
GO
GRANT EXECUTE ON  [Accounting].[usp_GetAllStocksConteggi] TO [SolaLetturaNoDanni]
GO
