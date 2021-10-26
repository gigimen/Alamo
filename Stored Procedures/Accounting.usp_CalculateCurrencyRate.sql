SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Accounting].[usp_CalculateCurrencyRate]
@currencyID					SMALLINT,
@ExtRate 					FLOAT,
@yesterdayGaming			DATETIME,
@IntRate 					FLOAT OUTPUT,
@TableRate					FLOAT OUTPUT,
@SellingRate				FLOAT OUTPUT,
@note						VARCHAR(1024) OUTPUT
AS

DECLARE 
@temp		varchar(50),
@tmp		float,
@YeaIntRate FLOAT,
@TaglioMin 					INT ,
@ExchangeRateMultiplier		SMALLINT 

SELECT 
	@TaglioMin = BD0,
	@ExchangeRateMultiplier = ExchangeRateMultiplier 
FROM CasinoLayout.tbl_Currencies WHERE CurrencyID = @currencyID

IF @TaglioMin IS NULL 
BEGIN
		raiserror('Invalid CurrencyID (%d) specified!!',16,-1,@currencyID)
		RETURN (1)
END

IF @currencyID = 0 --euros
BEGIN
/*
		--YG vuole cosi'
		set @IntRate = 1.01
		set @TableRate = 1.0
		set @SellingRate = 1.08
		set @note = 'Fixed manually from 24-04-2015!!'
		return 0
*/


	--find yesterday internal rate
	select 
		@YeaIntRate		= IntRate,
		@SellingRate	= SellingRate,
		@TableRate		= TableRate
		from [Accounting].[tbl_CurrencyGamingdateRates] 
		where GamingDate = @yesterdayGaming AND CurrencyID = @currencyID
	if (@YeaIntRate is null)
	begin
		declare @yeas varchar(256)
		set @yeas = CONVERT(varchar,@yesterdayGaming,113)
		raiserror('Euro Internal Rate of %s does not exists!!',16,-1,@yeas)
		RETURN (1)
	END

	--FINALLY WE CAN START CALCULATION

	----print 'Yesterday internal rate '+ convert(varchar(32),@IntRate)
	----print 'Yeasterday external rate '+ convert(varchar(32),@YeaExtRate)
	----print 'Today external rate '+ convert(varchar(32),@ExtRate)
	DECLARE
			@Threshold float,
			@ExchangeSellingRateGain float,
			@alfa float

	--get parameters from Configuration table
		
	select @temp = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'ExchangeRateThreshold' and VarType = 4
	if @temp is null
	begin
		raiserror('ExchangeRateThreshold not defined in table [GeneralPurpose].[ConfigParams]',16,-1)
		RETURN (1)
	END

	set @Threshold = CAST(@temp AS float)
	if (@Threshold is null)
	begin
		raiserror('ExchangeRateThreshold badly defined in table [GeneralPurpose].[ConfigParams]',16,-1)
		RETURN (1)
	END
		
	select @temp = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'ExchangeSellingRateGain' and VarType = 4
	if @temp is null
	begin
		raiserror('ExchangeSellingRateGain not defined in table [GeneralPurpose].[ConfigParams]',16,-1)
		RETURN (1)
	END

	set @ExchangeSellingRateGain = CAST(@temp AS float)
	if (@ExchangeSellingRateGain is null)
	begin
		raiserror('ExchangeSellingRateGain badly defined in table [GeneralPurpose].[ConfigParams]',16,-1)
		RETURN (1)
	END

	----print 'Threshold '+ convert(varchar(32),@Threshold)
	--print 'ExchangeSellingRateGain '+ convert(varchar(32),@ExchangeSellingRateGain)

	SET @tmp = @ExtRate  * (1 - @Threshold)

	SET @tmp =  GeneralPurpose.fn_Floor(@tmp,0.01)

	--print 'Nuovo cambio interno grezzo ' + convert(varchar(32),@tmp)
	SET @IntRate = @tmp
	SET @TableRate = @tmp

	SET @SellingRate = @tmp + @ExchangeSellingRateGain
	
	IF @IntRate = @YeaIntRate
		SET @note = NULL--'Il cambio interno di ieri (' + convert(varchar(32),@YeaIntRate) + ') non è cambiato'
	ELSE
		SET @note = 'Il cambio interno di ieri (' + CONVERT(VARCHAR(32),@YeaIntRate) + ') è cambiato a ' + CONVERT(VARCHAR(32),@IntRate)

	--print 'IntRate '+ convert(varchar(32),@IntRate)
	--print 'SellingRate '+ convert(varchar(32),@SellingRate)

END
ELSE --non euro currencies
BEGIN	

	--il cambio interno è 0.9 del cambio esterno
	SET @tmp = @ExtRate * 0.90
--	----print '90% of external rate is ' + convert(varchar(32),@tmp)
	--scale down the exchange rate to 1 unit (ex: 1 YPN = 0.0066 SFr. and not 100 YPN = 0.66 Sfr)
	SET @tmp = @tmp / @ExchangeRateMultiplier
	--print 'Nuovo cambio interno grezzo ' + convert(varchar(32),@tmp)
	--if the exchange of a TaglioMinimo is not multiple of 5 cents 
	-- then round the exchange rate to 0.05/TaglioMinimo  
	-- to avoid exchange rounds
	DECLARE @tagliominCambiato FLOAT
	SET @tagliominCambiato = (@tagliomin * @tmp / @ExchangeRateMultiplier ) * 20 -- equivalent to /0.05
	--print 'Taglio minimo cambiato ' + convert(varchar(32),@tagliominCambiato)
	IF (@tagliominCambiato - FLOOR(@tagliominCambiato)) <> 0.0
	BEGIN
		SET @IntRate = GeneralPurpose.fn_Floor(@tmp,0.05/@tagliomin)
		--print ' internal rate round to ' + convert(varchar(32),@IntRate)
	END
	ELSE 
		SET @IntRate = @tmp
END



--print @note  
RETURN 0

GO
