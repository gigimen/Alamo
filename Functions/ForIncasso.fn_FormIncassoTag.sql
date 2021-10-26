SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE FUNCTION [ForIncasso].[fn_FormIncassoTag] (
@gamingdate DATETIME,
@DenoID		INT
)  
RETURNS VARCHAR(64) 
AS  
BEGIN 
	declare @i varchar(64)


SELECT @i =
CASE 

WHEN ValueTypeID = 39		AND DenoID IN(162,163)				THEN 'CASSE_TITO_MOV_EUR'
WHEN ValueTypeID = 8											THEN 'CASSE_USD'
WHEN ValueTypeID = 9											THEN 'CASSE_GBP'
WHEN ValueTypeID = 23											THEN 'CASSE_CAD'
WHEN ValueTypeID = 24											THEN 'CASSE_AUD'
WHEN ValueTypeID = 25											THEN 'CASSE_NOK'
WHEN ValueTypeID = 26											THEN 'CASSE_DKK'
WHEN ValueTypeID = 27											THEN 'CASSE_SEK'
WHEN ValueTypeID = 28											THEN 'CASSE_JPY'
WHEN DenoID IN (63,150)											THEN 'CASSE_CHF_HANDPAY' --euro e chf
WHEN DenoID IN (65)												THEN 'CASSE_CHF_REFILLS'
WHEN DenoID IN (64,151)											THEN 'CASSE_CHF_SHORTPAY' --euro e chf
WHEN ValueTypeID = 10 AND DenoID = 100							THEN 'CASSE_JACKPOT'
WHEN ValueTypeID = 11											THEN 'CASHLESS_CASSE_MOV'
WHEN ValueTypeID = 31 AND DenoID IN (102, 103,140, 141)			THEN 'CASSE_TITO_MOV_CHF' 
--when @ValueTypeID = 31 and @DenoID in (102, 103)				then 'CASSE_TITO_MOV_CHF' 
--when @ValueTypeID = 31 and @DenoID in (140, 141)				then 'CASSE_TITO_MOV_EUR'  
--corretto in 115 2 148 perché prendiamo il dato scritto dalla cassiera e non quello letto al terminale
--when @ValueTypeID = 31 and @DenoID in (115)						then 'CASSE_TITO_MOV_CHF_PROMO' 
--when @ValueTypeID = 31 and @DenoID in (148)						then 'CASSE_TITO_MOV_EUR_PROMO'  
WHEN ValueTypeID = 31 AND DenoID IN (115,148)					THEN 'CASSE_TITO_MOV_CHF_PROMO' 
WHEN ValueTypeID = 20											THEN 'CASSE_CHF_RETT_DIFF'
WHEN ValueTypeID = 18 AND DenoID =71							THEN 'CASSE_CHF_MARKETING' 
WHEN ValueTypeID = 18 AND DenoID =114							THEN 'CASSE_MARKETING_TICKETS' 
WHEN ValueTypeID = 30 AND DenoID =90							THEN 'CASSE_CC_GLOBALCASH' 
WHEN ValueTypeID = 19											THEN 'CASSE_CHF_AMMINISTRAZIONE'
WHEN ValueTypeID = 57											THEN 'CASSE_EUR_AMMINISTRAZIONE'
WHEN ValueTypeID = 32 AND DenoID = 104							THEN 'CASSE_UTILE_VENDITAEURO' --utile cambio per vendita euro
WHEN ValueTypeID = 33											THEN 'CASSE_CHF_DENARO_TROVATO'
WHEN ValueTypeID = 13											THEN 'CASSE_CHF_TRANS_TAVOLI'
WHEN ValueTypeID = 49											THEN 'CASSE_EUR_TRANS_TAVOLI'
WHEN ValueTypeID = 35 AND denoid = 111							THEN 'CASSE_BONIFICI_CHF'
WHEN ValueTypeID = 22 AND DenoID = 77							THEN 'CASSE_DEPOSITI_MOV_CHF'
WHEN ValueTypeID = 48 AND DenoID = 177							THEN 'CASSE_DEPOSITI_MOV_EUR'
WHEN ValueTypeID = 53 AND denoid = 187							THEN 'CASSE_BONIFICI_EUR'
WHEN ValueTypeID = 41 AND denoid = 164							THEN 'CASSE_EUR_HANDPAY'
WHEN ValueTypeID = 41 AND denoid = 165							THEN 'CASSE_EUR_SHORTPAY'
WHEN ValueTypeID = 45 AND denoid = 174							THEN 'CASSE_CC_ADUNO'
WHEN ValueTypeID = 46 AND denoid = 179							THEN 'CASSE_EUR_RETT_DIFF'
WHEN ValueTypeID = 43 AND denoid = 180							THEN 'CASSE_EUR_DENARO_TROVATO'
-- 11.4.2019: removed form formulario incasso 
WHEN ValueTypeID = 50 AND denoid = 182 AND @gamingdate <= '04.10.2019'		THEN 'CASSE_EUR_TO_CHF'
-- 11.4.2019: removed form formulario incasso 
WHEN ValueTypeID = 51 AND denoid = 183	AND @gamingdate <= '04.10.2019'		THEN 'CASSE_CHF_TO_EUR'
WHEN ValueTypeID = 54 AND denoid = 188							THEN 'CASSE_CHF_GIOCHI_TEST'
WHEN ValueTypeID = 55 AND denoid = 189							THEN 'CASSE_EUR_GIOCHI_TEST'
WHEN ValueTypeID = 52	AND denoid = 184						THEN 'COMMISSIONI_EUR_CC_ADUNO'
WHEN ValueTypeID = 52	AND denoid = 185						THEN 'COMMISSIONI_EUR_ASSEGNI'
WHEN ValueTypeID = 44	AND denoid = 173						THEN 'CASSE_ASSEGNI'
WHEN ValueTypeID = 58	AND denoid = 208						THEN 'CASSE_EUR_MARKETING'
ELSE NULL
END
FROM CasinoLayout.tbl_Denominations WHERE DenoID = @DenoID
	RETURN @i
END







GO
