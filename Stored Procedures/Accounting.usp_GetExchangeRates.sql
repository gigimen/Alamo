SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetExchangeRates] 
@gaming			DATETIME,
@ValueTypeID 	INT
AS
IF @ValueTypeID IS NOT NULL
BEGIN
	--value type must exists and must be a foreign currency
	if not exists (select ValueTypeID from CasinoLayout.tbl_ValueTypes where ValueTypeID = @ValueTypeID and CurrencyID <> 4/*not chf*/)
	begin	
		raiserror ('Wrong value type (%d) specified ',16,1,@ValueTypeID)
		RETURN 1
	END
		SELECT [GamingDate]
			  ,[IntRate]
			  ,[ExtRate]
			  ,[YeasterdayExtRate]
			  ,[YeasterdayIntRate]
			  ,[RateIncrease]
			  ,[TableRate]
			  ,[SellingRate]
			  ,[Note]
			  ,[ValueTypeName]
			  ,[ExchangeRateMultiplier]
			  ,[CurrencyID]
			  ,[CurrencyAcronim]
			  ,[MinDenomination]
			  ,[ValueTypeID]
			  ,[InsertUserName]
			  ,[InsertTime]
			  ,[InsertSite]
			  ,[FixedUserName]
			  ,[FixedTime]
			  ,[FixedSite]
		FROM [Accounting].[vw_AllExchangeRates]
		WHERE GamingDate = @gaming AND ValueTypeID = @ValueTypeID
END
ELSE
	--all exchange rates for that value type
			SELECT [GamingDate]
			  ,[IntRate]
			  ,[ExtRate]
			  ,[YeasterdayExtRate]
			  ,[YeasterdayIntRate]
			  ,[RateIncrease]
			  ,[TableRate]
			  ,[SellingRate]
			  ,[Note]
			  ,[ValueTypeName]
			  ,[ExchangeRateMultiplier]
			  ,[CurrencyID]
			  ,[CurrencyAcronim]
			  ,[MinDenomination]
			  ,[ValueTypeID]
			  ,[InsertUserName]
			  ,[InsertTime]
			  ,[InsertSite]
			  ,[FixedUserName]
			  ,[FixedTime]
			  ,[FixedSite]
		FROM [Accounting].[vw_AllExchangeRates]
		WHERE GamingDate = @gaming 


GO
GRANT EXECUTE ON  [Accounting].[usp_GetExchangeRates] TO [SolaLetturaNoDanni]
GO
