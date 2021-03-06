SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [ForIncasso].[usp_GetInfoblatt]
@gaming DATETIME
AS

/*
declare @EuroRate float



declare @gaming DATETIME
set @gaming = '9.1.2020'

execute [ForIncasso].[usp_GetInfoblatt] @gaming


--*/

declare @EuroRate float

--get last available euro rate from alamo database
DECLARE @ultimogiorno DATETIME
SELECT @ultimogiorno = MAX(gamingdate) FROM Accounting.tbl_CurrencyGamingdateRates 
WHERE GamingDate <= @gaming AND CurrencyID = 0

SELECT @eurorate = IntRate 
FROM Accounting.tbl_CurrencyGamingdateRates 
WHERE GamingDate = @ultimogiorno AND CurrencyID = 0



IF 	@EuroRate IS NULL 
BEGIN
	RAISERROR('Non esiste il cambio euro del giorno specificato!!',16,-1)
END


DECLARE  @return TABLE
(
	Game VARCHAR(2),
	GamingDate DATETIME,
	TableCount INT,
	CashBox FLOAT,
	CashBoxCol VARCHAR(1),
	BSE float,
	BSECol VARCHAR(1),
	TroncTavoli	FLOAT,			 							
	TroncCol VARCHAR(1),
	TroncSala FLOAT,			
	TroncsalaCol VARCHAR(1),
	Visite INT,
	VisiteCol VARCHAR(1),
	FxRate FLOAT,											
	FxRateCol VARCHAR(1),
	Gastro FLOAT,												
	GastroCol VARCHAR(1)

)

INSERT INTO @return
(
    Game,
    GamingDate,
	TableCount,
    CashBox,
    CashBoxCol,
    BSE,
    BSECol,
    TroncTavoli,
    TroncCol,
    TroncSala,
    TroncsalaCol,
    Visite,
    VisiteCol,
    FxRate,
    FxRateCol,
    Gastro,
    GastroCol
)



SELECT	b.Game
		,@gaming								AS GamingDate
		,b.TableCount
--		,b.TableOpen
		,b.CashBox
		--,'F'									AS CashBoxCol
		,'I'									AS CashBoxCol
		,b.BSE
		,CASE 
			WHEN b.Game = 'AR' THEN 'B'
			WHEN b.Game = 'BJ' THEN 'C'
			WHEN b.Game = 'PB' THEN 'D'
			WHEN b.Game = 'UT' THEN 'E'
			WHEN b.Game = 'PK' THEN 'F'
			WHEN b.Game = 'SB' THEN 'H'
		END										AS BSECol
		,b.Tronc								AS TroncTavoli											
/*		,CASE 
			WHEN b.Game = 'AR' THEN 'I'
			WHEN b.Game = 'BJ' THEN 'J'
			WHEN b.Game = 'PB' THEN 'K'
			WHEN b.Game = 'UT' THEN 'L'
--			WHEN b.Game = 'SB' THEN 'F'
		END										AS TroncCol
*/		,CASE 
			WHEN b.Game = 'AR' THEN 'L'
			WHEN b.Game = 'BJ' THEN 'M'
			WHEN b.Game = 'PB' THEN 'N'
			WHEN b.Game = 'UT' THEN 'O'
			WHEN b.Game = 'SB' THEN 'P'
			WHEN b.Game = 'PK' THEN 'Q'
		END										AS TroncCol
		,ISNULL(s.[TotalTronc],0) /*+ ISNULL(tg.Totaltronc,0)*/				AS TroncSala			
		--,'N' AS TroncsalaCol
		,'S' AS TroncsalaCol
		,ISNULL(ck.Visite,0)					AS Visite											
		--,'P' AS VisiteCol
		,'U' AS VisiteCol
		,b.FxRate											
		--,'Q' AS FxRateCol
		,'V' AS FxRateCol
		,ISNULL(g.Total,0)						AS Gastro												
		--,'O' AS GastroCol
		,'T' AS GastroCol
FROM
(
/*

declare @EuroRate float

declare @gaming DATETIME
set @gaming = '8.26.2020'

set @EuroRate = 1.08

--*/
	select 
			Game,
			MAX(TableCount)			AS TableCount,
			MAX(TableOpen)			AS TableOpen,
			@gaming					AS GamingDate,
			@EuroRate				AS FxRate,
		   sum(CASE WHEN tav.CurrencyID = 0 THEN @EuroRate * CashBox ELSE CashBox end) AS CashBox,
		   sum(CASE WHEN tav.CurrencyID = 0 THEN @EuroRate * Tronc ELSE Tronc end) as Tronc,
		   sum(CASE WHEN tav.CurrencyID = 0 THEN @EuroRate * BSE ELSE BSE end) as BSE
	from
	(
/*

declare @EuroRate float

declare @gaming DATETIME
set @gaming = '8.26.2020'

select * FROM [ForIncasso].[fn_GetTischeAbrechnung] (@gaming)
set @EuroRate = 1.08

--*/	
	SELECT LEFT(c.Tag,2)														AS Game
			, count (StockID)													AS TableCount
			, sum (CASE WHEN c.LastGamingDate= @gaming THEN 1 ELSE 0 end)		AS TableOpen
			,c.CurrencyID
			,ISNULL(SUM(c.[CashBox]),0)											AS CashBox
			,ISNULL(SUM(Chiusura - Apertura + Credits -Fills + CashBox),0)		AS BSE
			,ISNULL(SUM(c.[Tronc]),0)											AS Tronc
	FROM [ForIncasso].[fn_GetTischeAbrechnung] (@gaming) c
	GROUP BY LEFT(Tag,2),c.CurrencyID
	) tav
	group BY Game
) b
LEFT OUTER JOIN [Accounting].[vw_DailyTroncSala] s ON s.GamingDate = b.GamingDate
--LEFT OUTER JOIN [Accounting].[vw_DailyTroncGastro] tg ON tg.GamingDate = b.GamingDate
LEFT OUTER JOIN Snoopy.tbl_EntrateSummary ck ON ck.GamingDate = b.GamingDate
LEFT OUTER JOIN  [GASTRO].[GastroHelper].[Accounting].[vw_TotalDailyBalance] g  ON g.GamingDate = b.GamingDate



INSERT INTO @return
	(
		Game,
		GamingDate,
		TableCount,
		CashBox,
		CashBoxCol,
		BSE,
		BSECol,
		TroncTavoli,
		TroncCol,
		TroncSala,
		TroncsalaCol,
		Visite,
		VisiteCol,
		FxRate,
		FxRateCol,
		Gastro,
		GastroCol
	)
SELECT
	   'ZZ', -- Game - varchar(2)
		@gaming, -- GamingDate - datetime
		1, -- TableCount - int
		0, -- CashBox - float
		'I', -- CashBoxCol - varchar(1)
		[BSECHF], -- BSE - float
		'G', -- BSECol - varchar(1)
		0, -- TroncTavoli - float
		'Y', -- TroncCol - varchar(1)
		0, -- TroncSala - float
		'S', -- TroncsalaCol - varchar(1)
		0, -- Visite - int
		'U', -- VisiteCol - varchar(1)
		0, -- FxRate - float
		'V', -- FxRateCol - varchar(1)
		0, -- Gastro - float
		'T'  -- GastroCol - varchar(1)
FROM [Accounting].[vw_TorneoPokerBSE]
WHERE lastday = @gaming






SELECT * FROM @return
ORDER BY Game

--select * from [GASTRO].[GastroHelper].[Accounting].[vw_TotalDailyBalance] where gamingdate = '9.20.2020'
GO
