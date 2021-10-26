SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [ForIncasso].[vw_AllExtExchangeRates]
WITH SCHEMABINDING
AS

SELECT 
CurrencyAcronim,
YeasterdayExtRate,
IntRate,
GamingDate 

FROM [Accounting].[vw_AllExchangeRates]

GO
