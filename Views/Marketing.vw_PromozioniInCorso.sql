SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Marketing].[vw_PromozioniInCorso]
WITH SCHEMABINDING
AS
SELECT 
p.OffertaPremioID, 
p.PromotionID,   
p.Promozione, 
p.PremioID, 
p.Premio, 
[GeneralPurpose].[fn_GetGamingLocalDate2]
(
GetUtcDate(),
1,
4--use cassa StockTypeID
) as GamingDate,
p.ConsegnaSiteTypeID,
p.ConsegnataAl,
p.ProntaConsegna,
p.ValidaDal,
p.ValidaAl,
p.ValiditaRitiro,
p.PromotionScope
FROM  Marketing.vw_AllOffertaPremi p 
where p.ProntaConsegna = 1 --premio is in pronta Consegna (i.e. non ordine is necessary)
and p.PromozioneInCorso = 1
GO
