SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [GoldenClub].[fn_CheckPromotionValidityDefined] (
@ValiditaRitiro 	int,
@PromotionID int
)
RETURNS bit 
AS  
BEGIN 
DECLARE @r BIT

	if (
		@ValiditaRitiro = 4 and 
			EXISTS (
					select t.PromotionID 
					from Marketing.tbl_Promozioni t 
					where t.PromotionID = @PromotionID and t.ValidaDal is not NULL
					)) or 
		@ValiditaRitiro <> 4
		SET @r = 1
	ELSE
		SET @r = 0  

	RETURN @r

END
GO
