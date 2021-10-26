SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_GetRifornimentiKiosk]
(
      @Gamingdate DATETIME
)
/*

select * from [Accounting].[fn_GetRifornimentiKiosk] ('4.16.2019')

*/
RETURNS @RifList TABLE (Nome VARCHAR(32), Amount INT)
--WITH SCHEMABINDING
AS
BEGIN
      INSERT INTO @RifList
            SELECT Nome,Amount FROM [Accounting].[vw_RifornimentiKiosk]
			WHERE GamingDate = @Gamingdate

      INSERT INTO @RifList
		SELECT 'KIOSK_STOCK_OGGI_' + UPPER(RIGHT(Tag,4)),Totale
		FROM CasinoLayout.vw_AllStockCompositionTotals 
		WHERE StockTypeId IN(18,20) 
		AND	StartOfUseGamingDate <= @Gamingdate  
		AND (EndOfUseGamingDate >= @Gamingdate OR EndOfUseGamingDate IS NULL)

      RETURN 
END

GO
