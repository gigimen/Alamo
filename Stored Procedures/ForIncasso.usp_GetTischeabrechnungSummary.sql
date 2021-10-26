SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO




CREATE PROCEDURE [ForIncasso].[usp_GetTischeabrechnungSummary]
@gaming			datetime
AS
/*

declare @gaming			datetime
set @gaming = '6.28.2019'

execute [ForIncasso].[usp_GetTischeabrechnungSummary] @gaming	

		
--*/

declare @Summary as table (
ForIncassoTag varchar(64),
Amount FLOAT)

declare @EuroRate float
declare @t table (
	Tag varchar(32),
	CurrencyID int,
	Acronim VARCHAR(4),
	GamingDate datetime,
	Apertura int,
	Chiusura int,
	Fills int,
	Credits int,
	EstimatedDrop INT,
	CashBox INT,
	Tronc float,
	LuckyChipsPezzi INT,
	LuckyChipsValue	INT
	)
INSERT INTO @t
(
    Tag,
    CurrencyID,
    Acronim,
    GamingDate,
    Apertura,
    Chiusura,
    Fills,
    Credits,
    EstimatedDrop,
    CashBox,
    Tronc,
    LuckyChipsPezzi,
	LuckyChipsValue
)
execute [ForIncasso].[usp_GetTischeAbrechnung] @gaming,@EuroRate OUTPUT


--SELECT * FROM @t

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_APERTURA_CHF',isnull(sum(Apertura			),0) as Amount from @t where CurrencyID = 4

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_APERTURA_EUR',isnull(sum(Apertura			),0) as Amount from @t where CurrencyID = 0

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_CHIUSURA_CHF',isnull(sum(Chiusura			),0) as Amount from @t where CurrencyID = 4

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_CHIUSURA_EUR',isnull(sum(Chiusura			),0) as Amount from @t where CurrencyID = 0

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_FILLS_CHF',isnull(sum(Fills			),0) as Amount from @t where CurrencyID = 4

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_FILLS_EUR',isnull(sum(Fills			),0) as Amount from @t where CurrencyID = 0

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_CREDITS_CHF',isnull(sum(Credits			),0) as Amount from @t where CurrencyID = 4

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_CREDITS_EUR',isnull(sum(Credits			),0) as Amount from @t where CurrencyID = 0

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_CASHBOX_TOT_CHF',isnull(sum(CashBox			),0) as Amount from @t where CurrencyID = 4

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_CASHBOX_TOT_EUR',isnull(sum(CashBox			),0) as Amount from @t where CurrencyID = 0

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_LUCKY',isnull(sum(LuckyChipsPezzi			),0) as Amount from @t where CurrencyID = 0

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_AR_BSE_CHF',isnull(sum(Chiusura),0) + isnull(sum(CashBox),0) - isnull(sum(Apertura),0) + isnull(sum(Credits),0) - isnull(sum(Fills),0) as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'AR'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_AR_BSE_EUR', ISNULL(sum(Chiusura + CashBox - Apertura + Credits - Fills			),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'AR'
--add CashBox to CHF BSE 
--UPDATE @Summary SET Amount += (SELECT ISNULL(SUM(CashBox),0) * @EuroRate FROM @t where CurrencyID = 0 and LEFT(Tag,2) = 'AR')
--WHERE ForIncassoTag = 'TAVOLI_AR_BSE_CHF'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_BJ_BSE_CHF',isnull(sum(Chiusura),0) + isnull(sum(CashBox),0) - isnull(sum(Apertura),0) + isnull(sum(Credits),0) - isnull(sum(Fills),0)  as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'BJ'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_BJ_BSE_EUR', ISNULL(sum(Chiusura + CashBox - Apertura + Credits - Fills			),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'BJ'
--add CashBox to CHF BSE 
--UPDATE @Summary SET Amount += (SELECT ISNULL(SUM(CashBox),0) * @EuroRate FROM @t where CurrencyID = 0 and LEFT(Tag,2) = 'BJ')
--WHERE ForIncassoTag = 'TAVOLI_BJ_BSE_CHF'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_PB_BSE_CHF',isnull(sum(Chiusura),0) + isnull(sum(CashBox),0) - isnull(sum(Apertura),0) + isnull(sum(Credits),0) - isnull(sum(Fills),0)  as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'PB'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_PB_BSE_EUR',ISNULL(sum(Chiusura + CashBox - Apertura + Credits - Fills			),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'PB'
--add CashBox to CHF BSE 
--UPDATE @Summary SET Amount += (SELECT ISNULL(SUM(CashBox),0) * @EuroRate FROM @t where CurrencyID = 0 and LEFT(Tag,2) = 'PB')
--WHERE ForIncassoTag = 'TAVOLI_PB_BSE_CHF'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_UT_BSE_CHF',isnull(sum(Chiusura),0) + isnull(sum(CashBox),0) - isnull(sum(Apertura),0) + isnull(sum(Credits),0) - isnull(sum(Fills),0)  as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'UT'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_UT_BSE_EUR',ISNULL(sum(Chiusura + CashBox - Apertura + Credits - Fills			),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'UT'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_SB_BSE_CHF',isnull(sum(Chiusura),0) + isnull(sum(CashBox),0) - isnull(sum(Apertura),0) + isnull(sum(Credits),0) - isnull(sum(Fills),0)  as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'SB'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_SB_BSE_EUR',ISNULL(sum(Chiusura + CashBox - Apertura + Credits - Fills			),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'SB'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_AR_TRONC_CHF',isnull(sum(Tronc	),0) as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'AR'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_AR_TRONC_EUR',isnull(sum(Tronc	),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'AR'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_BJ_TRONC_CHF',isnull(sum(TRONC		),0) as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'BJ'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_BJ_TRONC_EUR',isnull(sum(TRONC	),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'BJ'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_PB_TRONC_CHF',isnull(sum(TRONC	),0) as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'PB'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_PB_TRONC_EUR',isnull(sum(TRONC	),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'PB'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_UT_TRONC_CHF',isnull(sum(TRONC	),0) as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'UT'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_UT_TRONC_EUR',isnull(sum(TRONC	),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'UT'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_SB_TRONC_CHF',isnull(sum(TRONC	),0) as Amount from @t where CurrencyID = 4 and LEFT(Tag,2) = 'SB'

INSERT INTO @Summary(ForIncassoTag,Amount)
select 'TAVOLI_SB_TRONC_EUR',isnull(sum(TRONC	),0) as Amount from @t where CurrencyID = 0 and LEFT(Tag,2) = 'SB'

/*
INSERT INTO @Summary(ForIncassoTag,Amount)
SELECT ForIncassoTag,Amount FROM [ForIncasso].[vw_DailyTavoliTotRipristinato] WHERE GamingDate = @gaming

*/


INSERT INTO @Summary(ForIncassoTag,Amount)

/*

inserisci anche i dati del conteggio

declare @gaming			datetime
set @gaming = '7.14.2019'
--*/

SELECT 
      'CONTEGGIO_GETTONI_' + [CurrencyAcronim] AS ForIncassoTag
      ,[TotQuantity] AS Amount
FROM [Accounting].[vw_DailyConteggioGettoni]
WHERE [GamingDate] = @gaming

SELECT * from @Summary
GO
