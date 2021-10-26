SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [ForIncasso].[fn_GetTischeAbrechnung] 
(
@gaming			DATETIME
)

RETURNS @TischeAbrechnung TABLE 
(
	Tag					VARCHAR(16),
	CurrencyID			INT,
	Acronim				VARCHAR(4),
	StockID				INT,
	GamingDate			DATETIME,
	LastGamingDate		DATETIME,
	OraApertura			DATETIME,
	OraChiusura			DATETIME,
	LifeCycleID			INT,
	Apertura			INT,
	Chiusura			INT,
	Fills				INT,
	Credits				INT,
	EstimatedDrop		INT,
	CashBox				INT,
	BSE					INT,
	Tronc				float,
	LuckyChipsPezzi		INT,
	LuckyChipsValue		INT
)
--WITH SCHEMABINDING
AS
BEGIN

/*

DECLARE @gaming DATETIME

SET @gaming = '9.1.2019'

--select * FROM [ForIncasso].[fn_GetChiusureTavoli] (@gaming)
--select * from [ForIncasso].[fn_GetTischeAbrechnung] (@gaming)

--*/
INSERT into @TischeAbrechnung
(
    Tag,
    CurrencyID,
    Acronim,
    StockID,
    GamingDate,
    LastGamingDate,
    OraApertura,
    OraChiusura,
    LifeCycleID,
    Apertura,
    Chiusura,
    Fills,
    Credits,
    EstimatedDrop,
    CashBox,
    BSE,
    Tronc,
    LuckyChipsPezzi,
    LuckyChipsValue
)
/*

DECLARE @gaming DATETIME

SET @gaming = '9.1.2019'

--*/

SELECT
	Tag,
	CurrencyId,
	Acronim,
	StockID,
	GamingDate,
	LastGamingDate,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			NULL
		ELSE
			OraApertura
	END								AS OraApertura,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			NULL
		ELSE
			OraChiusura
	END								AS OraChiusura,
	LastLFID						AS LifeCycleID,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			NextApertura	--cast(NextApertura as int)
		ELSE
			Apertura		--cast(Apertura as int)
	END								AS Apertura,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			NextApertura	--cast(NextApertura as int)
		ELSE
			Chiusura		--cast(Chiusura as int)
	END								AS Chiusura,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			0
		ELSE
			Fills			--cast(Fills as int)
	END								AS Fills,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			0
		ELSE
			Credits			--cast(Credits as int)
	END								AS Credits,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			0
		ELSE
			EstimatedDrop	--cast(EstimatedDrop as int)
	END								AS EstimatedDrop,
	CashBox,
	CASE 
		WHEN LastGamingDate < GamingDate THEN
			CashBox	--cast(totConteggio as int)
		ELSE
			Chiusura + CashBox - Apertura + Credits - Fills --cast(Chiusura + totConteggio - Apertura + Credits - Fills as int)
	END								AS BSE,
	Tronc,
	LuckyChips						AS LuckyChipsPezzi,
	LuckyChips * 5					AS LuckyChipsValue
FROM [ForIncasso].[fn_GetChiusureTavoli] (@gaming)

ORDER BY stockid


RETURN
END
GO
