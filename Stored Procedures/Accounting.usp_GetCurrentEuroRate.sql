SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [Accounting].[usp_GetCurrentEuroRate] 
AS

declare @GamingDate datetime
set @GamingDate = GeneralPurpose.fn_GetGamingLocalDate2(GetUTCDate(),1,7) --CC GamingDate

SELECT [GamingDate]
	,[IntRate]
	,[ExtRate]
	,[Note]
	,[YeasterdayExtRate]
	,[YeasterdayIntRate]
	,[RateIncrease]
	,[TableRate]
	,[SellingRate]
	,[CurrencyID]
	,[ExchangeRateMultiplier]
	,[CurrencyAcronim]
	,[MinDenomination]
	,[InsertUserName]
	,[InsertTime]
	,[InsertSite]
	,[FixedUserName]
	,[FixedTime]
	,[FixedSite]
FROM [Accounting].vw_AllExchangeRates
WHERE GamingDate = @GamingDate AND CurrencyID = 0
GO
