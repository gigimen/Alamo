SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Marketing].[fn_PremioDaRitirare] (
@AssegnazionePremioID 	int
)
RETURNS bit 
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @r BIT

	--il premio è già stato ritirato
	SELECT @r =
			case
				WHEN ord.RitiratoTimeStampUTC IS NOT NULL THEN 0 --already ritirato
				ELSE
					--controlla se è ancora nell'intervallo di ritirabilità  
					CASE 
						WHEN o.ValiditaRitiro = 0 THEN 1 --'Forever'
						WHEN o.ValiditaRitiro = 1 THEN 1 --'OneTimeOnly'
						WHEN o.ValiditaRitiro = 2 THEN --'OnePerGamingDate'
							--controlla che sia nello stesso GamingDate
							case 
								WHEN [GeneralPurpose].[fn_GetGamingDate] (ord.InsertTimeStampUTC,1,default) = 
										 [GeneralPurpose].[fn_GetGamingDate] (GETUTCDATE(),1,default) THEN 1
								ELSE 0
							END	
						WHEN o.ValiditaRitiro = 3 THEN --'Within ' + CAST(o.WithinNDays as varchar(16)) + ' days'
							CASE 
							   --sono trascorsi già o.WithinNDays giorni?
								WHEN DATEDIFF(
									DAY,
									[GeneralPurpose].[fn_GetGamingDate] (ord.InsertTimeStampUTC,1,default),
									[GeneralPurpose].[fn_GetGamingDate] (GETUTCDATE(),1,default) 
									) 
								< o.WithinNDays THEN 1 
								ELSE 0
							END
						WHEN o.ValiditaRitiro = 4 THEN --'Fino al ' + CAST(pro.ValidaAl as varchar(16))
							CASE 
							   --è già passata la fine della promozione?
								WHEN [GeneralPurpose].[fn_GetGamingDate] (GETUTCDATE(),1,default)
								<= pro.ValidaAl THEN 1 
								ELSE 0
							END
					END 
			END
		FROM [Marketing].[tbl_AssegnazionePremi] ord 
		INNER JOIN [Marketing].[tbl_OffertaPremi] o ON ord.OffertaPremioID = o.OffertaPremioID
		INNER JOIN [Marketing].[tbl_Premi] pre ON o.PremioID = pre.PremioID 
		INNER JOIN [Marketing].[tbl_Promozioni] pro ON o.PromotionID = pro.PromotionID 	
		WHERE AssegnazionePremioID = @AssegnazionePremioID
	RETURN @r
END
GO
