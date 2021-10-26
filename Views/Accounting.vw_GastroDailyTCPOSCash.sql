SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_GastroDailyTCPOSCash]
AS
	SELECT CASE WHEN [SHOP_ID] = 1 THEN 65 ELSE 67 END AS Stockid
		,[Data] AS gamingdate
		,ISNULL(SUM(credit_card_amount),0)	AS CarteDiCredito
		,ISNULL(SUM(voucher_amount),0)		AS Buoni
		,ISNULL(SUM(debitor1_amount),0)		AS Debitori
		,ISNULL(SUM(debitor2_amount),0) + ISNULL(SUM(card_amount),0) + ISNULL(SUM(other_prepayment_amount),0) AS Altro
		,ISNULL(SUM([cash_amount]),0)			AS Cash
	FROM [Gastro].[GastroHelper].[Accounting].[vw_TOTALI_PER_TILL_E_DATE] 
	GROUP BY CASE WHEN [SHOP_ID] = 1 THEN 65 ELSE 67 END ,[Data]
GO
