SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetCurrencyRates] 
@gaming			DATETIME,
@CurrencyID 	smallint
AS
IF @CurrencyID IS NOT NULL
BEGIN
	--value type must exists and must be a foreign currency
	if not exists (select CurrencyID from CasinoLayout.tbl_Currencies where CurrencyID = @CurrencyID and CurrencyID <> 4/*not chf*/)
	begin	
		raiserror ('Wrong @CurrencyID (%d) specified ',16,1,@CurrencyID)
		RETURN 1
	END

	--get last seen currency rate
	SELECT @gaming = max([GamingDate])
	FROM [Accounting].[vw_AllCurrencyRates]
	WHERE GamingDate <= @gaming AND CurrencyID = @CurrencyID

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
	  FROM [Accounting].[vw_AllCurrencyRates]
	  WHERE GamingDate = @gaming AND CurrencyID = @CurrencyID
END
ELSE
	--get last seen currency rate
		SELECT @gaming = max([GamingDate])
	  FROM [Accounting].[vw_AllCurrencyRates]
	  WHERE GamingDate <= @gaming AND CurrencyID <> 4  --NOT chf

	--all currency rates for that value type
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
	  FROM [Accounting].[vw_AllCurrencyRates]
	  WHERE GamingDate = @gaming and CurrencyID <> 4  --NOT chf


GO
