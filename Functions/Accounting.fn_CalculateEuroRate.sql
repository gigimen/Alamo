SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_CalculateEuroRate] (
@YeaExtRate			FLOAT,
@TodayExtRate 		float,
@YeaIntRate			FLOAT
)  
RETURNS float 
WITH SCHEMABINDING
AS  
BEGIN 
	declare @outVal float


	declare @temp varchar(50)
	select  @temp =VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'ExchangeRateLowLimit' and VarType = 4
	if @temp is null
	begin
		--PRINT 'ExchangeRateLowLimit not defined in table [GeneralPurpose].[ConfigParams]'
		return (0)
	end
	
	--get parameters from Configuration table
	declare @LowLimit float
	set @LowLimit = CAST(@temp AS float)
	if @LowLimit is null
	begin
		--PRINT 'ExchangeRateLowLimit badly defined in table [GeneralPurpose].[ConfigParams]'
		return (0)
	end

	select @temp = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'ExchangeRateHighLimit' and VarType = 4
	if @temp is null
	begin
		--PRINT 'ExchangeRateHighLimit not defined in table [GeneralPurpose].[ConfigParams]'
		return (0)
	end
	declare @HighLimit float
	set @HighLimit = CAST(@temp AS float)
	if (@HighLimit is null)
	begin
		--PRINT 'ExchangeRateHighLimit badly defined in table [GeneralPurpose].[ConfigParams]'
		return (0)
	end
	
	select @temp = VarValue from [GeneralPurpose].[ConfigParams] where VarName = 'ExchangeRateThreshold' and VarType = 4
	if @temp is null
	begin
		--PRINT 'ExchangeRateThreshold not defined in table [GeneralPurpose].[ConfigParams]'
		return (0)
	END

	declare @Threshold float
	set @Threshold = CAST(@temp AS float)
	if (@Threshold is null)
	begin
		--PRINT 'ExchangeRateThreshold badly defined in table [GeneralPurpose].[ConfigParams]'
		return (0)
	end
	
	--FINALLY WE CAN START CALCULATION

	--PRINT 'Yesterday internal rate '+ convert(varchar(32),@YeaIntRate)
	--PRINT 'Yeasterday external rate '+ convert(varchar(32),@YeaExtRate)
	--PRINT 'Today external rate '+ convert(varchar(32),@TodayExtRate)
	--PRINT 'Low limit '+ convert(varchar(32),@LowLimit)
	--PRINT 'High limit '+ convert(varchar(32),@HighLimit)
	--PRINT 'Threshold '+ convert(varchar(32),@Threshold)
	IF ABS(@YeaExtRate - @TodayExtRate) < 0.00001 --external rate did not change: don't change the internal rate as well
	BEGIN
		--PRINT  'External rate did not change: do not change the internal rate'
		SET @outVal = @YeaIntRate
	END     
	ELSE 
	BEGIN
		declare @alfa float
		set @alfa = @TodayExtRate - @YeaIntRate
		--PRINT 'Alfa '+ convert(varchar(32),@alfa)
		if(@alfa <= @HighLimit and @alfa >= @LowLimit)
			--PRINT 'Alfa(' + convert(varchar(32),@alfa) + ') In the limits: do not change the internal rate'
			SET @outVal = @YeaIntRate
		else
		begin
			declare @beta float
			declare @tmp float
			set @beta = @TodayExtRate - @Threshold
			--PRINT 'Out of the limits beta is ' + convert(varchar(32),@beta)
			set @beta = GeneralPurpose.fn_Floor(@beta,0.01)
			--PRINT 'Beta floored to ' + convert(varchar(32),@beta)
			--now check if it is multiple of 0.05
			set @tmp = (@beta * 100) / 5
			if(ROUND(@tmp,0) <> @tmp )
			begin
				set @outVal = @beta
				--PRINT 'beta(' + convert(varchar(32),@beta) +') is not multiple of 0.05 int rate is ' + convert(varchar(32),@outVal)
			end
			else
			begin
				if @alfa <= @HighLimit
				BEGIN
					set @outVal = @beta - 0.01
					--PRINT 'beta(' + convert(varchar(32),@beta) +') is multiple of 0.05 and alfa is ' + convert(varchar(32),@alfa) + ' int rate lowered down to ' + convert(varchar(32),@outVal)
				END
				ELSE
				BEGIN          
					set @outVal = @beta + 0.01
					IF ABS(@TodayExtRate-@outVal) <0.01 -->= 0.01 --ok to rise we still gain some money here
--					BEGIN
               
						--PRINT 'beta(' + convert(varchar(32),@beta) +') is multiple of 0.05 and alfa is ' + convert(varchar(32),@alfa) + ' int rate rised to ' + convert(varchar(32),@outVal)
--					end
--					ELSE
					BEGIN
						-- go back to 0.02
							set @outVal = @outVal - 0.02
							--PRINT 'beta(' + convert(varchar(32),@beta) +') is multiple of 0.05 and alfa is ' + convert(varchar(32),@alfa) + ' int rate cannot rise: set to ' + convert(varchar(32),@outVal)
					end              
				END
			end
		END
	END
	return (@outVal)
END





GO
