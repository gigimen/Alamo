SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE VIEW  [Marketing].[vw_AllOffertaPremi]
WITH SCHEMABINDING
AS
SELECT    
o.OffertaPremioID,
o.PremioID, 
pre.FName as Premio, 
pro.PromotionID,
pro.FDescription AS Promozione,
o.[ConsegnaSiteTypeID],
pre.ProntaConsegna, 
st.FName AS ConsegnataAl,
o.ValiditaRitiro,
--0=Always,1=OnTimeOnly,2=OnePerGamingDate,3=WithinNdays,4=PromotionValidity
CASE 
WHEN o.ValiditaRitiro = 0 THEN 'Forever'
WHEN o.ValiditaRitiro = 1 THEN 'OneTimeOnly'
WHEN o.ValiditaRitiro = 2 THEN 'OnePerGamingDate'
WHEN o.ValiditaRitiro = 3 THEN 'Within ' + CAST(o.WithinNDays as varchar(16)) + ' days'
WHEN o.ValiditaRitiro = 4 THEN 'Fino al ' + CAST(pro.ValidaAl as varchar(16))
END AS ValiditaRitiroDesc,
o.WithinNDays,
pro.ValidaDal,
pro.ValidaAl,
pro.PromotionScope,
CASE
	WHEN pro.ValidaAl is NULL AND pro.ValidaDal IS NULL THEN 1
	ELSE
		case 
			when 
			(pro.ValidaDal is not null and pro.ValidaDal <= [GeneralPurpose].[fn_GetGamingLocalDate2]
							(
							GetUtcDate(),
							1,
							4--use cassa StockTypeID
							)
			)
			and --an expirationdate is not defined or has passed already
			(
				pro.ValidaAl is null or pro.ValidaAl >= [GeneralPurpose].[fn_GetGamingLocalDate2]
							(
							GetUtcDate(),
							1,
							4--use cassa StockTypeID
							)
			)
			THEN 1
		ELSE 0
	END
  END AS PromozioneInCorso  
FROM [Marketing].[tbl_OffertaPremi] o
INNER JOIN [Marketing].[tbl_Premi] AS pre ON o.PremioID = pre.PremioID 
INNER JOIN [Marketing].[tbl_Promozioni] AS pro ON o.PromotionID = pro.PromotionID 
INNER JOIN CasinoLayout.SiteTypes st on st.SiteTypeID = o.[ConsegnaSiteTypeID]
GO
