SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [ForIncasso].[fn_GetRifornimentiKiosk]
(
      @Gamingdate DATETIME
)
/*

select * from [Accounting].[fn_GetRifornimentiKiosk] ('4.16.2019')

*/
RETURNS @RifList TABLE (ForIncassoTag VARCHAR(32), Amount INT)
--WITH SCHEMABINDING
AS
BEGIN
      INSERT INTO @RifList
            SELECT ForIncassoTag,Amount FROM [ForIncasso].[vw_RifornimentiKiosk]
			WHERE GamingDate = @Gamingdate

      INSERT INTO @RifList
		SELECT 
		'KIOSK_STOCK_OGGI_' + UPPER(RIGHT(Tag,4)) AS ForIncassoTag,
		Totale AS Amount
		FROM CasinoLayout.vw_AllStockCompositionTotals 
		WHERE StockTypeId IN(18,20) 
		AND	StartOfUseGamingDate <= @Gamingdate  
		AND (EndOfUseGamingDate >= @Gamingdate OR EndOfUseGamingDate IS NULL)

      RETURN 
END


GO
