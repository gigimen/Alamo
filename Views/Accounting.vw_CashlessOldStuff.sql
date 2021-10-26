SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_CashlessOldStuff]
--WITH SCHEMABINDING
AS
SELECT	pu.[CardCode]
		,pu.[AmountCents]
		,CONVERT(FLOAT,pu.[AmountCents]) / 100.0 AS Importo
      ,pu.[TimeStampLocal]
      ,pu.[RedeemTimeStampLocal]
      ,pu.[RedeemStockID]
	  ,st.Tag	AS RedeemTag
FROM [OldStuff].[cashless].[tbl_CardPurses] pu
LEFT OUTER JOIN CasinoLayout.Stocks st ON st.StockID = pu.RedeemStockID
--WHERE pu.[CardCode] = '%s'
GO
