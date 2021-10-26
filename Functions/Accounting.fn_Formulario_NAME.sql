SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Accounting].[fn_Formulario_NAME] (
@ValueTypeID	int,
@DenoID		int
)  
RETURNS varchar(64) 
AS  
BEGIN 
	declare @i varchar(64)


select @i =
case 

when @ValueTypeID = 7											then 'CASSE_EUR'
when @ValueTypeID = 8											then 'CASSE_USD'
when @ValueTypeID = 9											then 'CASSE_GBP'
when @ValueTypeID = 23											then 'CASSE_CAD'
when @ValueTypeID = 24											then 'CASSE_AUD'
when @ValueTypeID = 25											then 'CASSE_NOK'
when @ValueTypeID = 26											then 'CASSE_DKK'
when @ValueTypeID = 27											then 'CASSE_SEK'
when @ValueTypeID = 28											then 'CASSE_JPY'
when @ValueTypeID = 10 and @DenoID in (63,150)					then 'CASSE_HANDPAY' --euro e chf
when @ValueTypeID = 10 and @DenoID = 65							then 'CASSE_REFILLS'
when @ValueTypeID = 10 and @DenoID in (64,151)					then 'CASSE_SHORTPAY' --euro e chf
when @ValueTypeID = 10 and @DenoID = 100						then 'CASSE_JACKPOT'
when @ValueTypeID = 11											then 'CASSE_CASHLESS_MOV'
when @ValueTypeID = 31 and @DenoID in (102, 103)				then 'CASSE_TITO_MOV_CHF' 
when @ValueTypeID = 31 and @DenoID in (140, 141)				then 'CASSE_TITO_MOV_EUR'  
--corretto in 115 2 148 perché prendiamo il dato scritto dalla cassiera e non quello letto al terminale
when @ValueTypeID = 31 and @DenoID in (115)						then 'CASSE_TITO_MOV_CHF_PROMO' 
when @ValueTypeID = 31 and @DenoID in (148)						then 'CASSE_TITO_MOV_EUR_PROMO'  
when @ValueTypeID = 20											then 'CASSE_RETT_DIFF'
when @ValueTypeID = 29											then 'CASSE_ASSEGNI'
when @ValueTypeID = 18 and @DenoID =71							then 'CASSE_MARKETING' 
when @ValueTypeID = 18 and @DenoID =114							then 'CASSE_MARKETING_TICKETS' 
when @ValueTypeID = 30 and @DenoID =90							then 'CASSE_CC_GLOBALCASH' 
when @ValueTypeID = 30 and @DenoID =98							then 'CASSE_CC_ADUNO'
when @ValueTypeID = 19											then 'CASSE_AMMINISTRAZIONE'
when @ValueTypeID = 32 and @DenoID = 104						then 'CASSE_UTILE_VENDITAEURO' --utile cambio per vendita euro
when @ValueTypeID = 32 and @DenoID = 152						then 'CASSE_UTILE_COMMISSIONI' --commissioni
when @ValueTypeID = 33											then 'CASSE_DENARO_TROVATO'
when @ValueTypeID = 35											then 'CASSE_BONIFICI'
when @ValueTypeID = 22 and @DenoID = 77							then 'CASSE_DEPOSITI_MOV'
ELSE NULL
end

	return @i
END





GO
