SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [ForIncasso].[vw_AllExchangeRates]
WITH SCHEMABINDING
AS



SELECT	'CAMBIO_RATA_INT_' + CurrencyAcronim AS 'ForIncassoTag',
		IntRate AS Amount,
		GamingDate
 FROM [Accounting].[vw_AllExchangeRates]

GO
