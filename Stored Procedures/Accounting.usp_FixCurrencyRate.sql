SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [Accounting].[usp_FixCurrencyRate]
@CurrencyID int,
@gamingDate datetime output,
@UserAccessID int,
@IntRate float output,
@TableRate float output,
@SellingRate float output
AS

--declare @SellingRate float
declare @StockTypeID int
select @StockTypeID = StockTypeID from CasinoLayout.StockTypes where FDescription = 'Trolleys'
if (@StockTypeID is null) 
begin
	raiserror('Trolley StockTypeID not defined',16,-1)
	return (1)
end
if @gamingDate is null
	set @gamingDate = GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				@StockTypeID
				)
if 	@CurrencyID is null  
	or not exists(
		select CurrencyID from CasinoLayout.tbl_Currencies 
		where  CurrencyID = @CurrencyID 
		and CurrencyID <> 4 --not chf		
		)
begin
	raiserror('Ivalid CurrencyID (%d): is a foreign currency!!',16,@CurrencyID)
	return (1)
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_FixExchangeRate

BEGIN TRY  




	declare @Corso float
	select 	@Corso = IntRate,
		@TableRate = TableRate,
		@SellingRate = SellingRate
		from [Accounting].[tbl_CurrencyGamingdateRates]
		where CurrencyID = @CurrencyID 
		and GamingDate = @GamingDate

	if @Corso is null --not enterd yet
	begin
		--get last internal exchange rate
		select 	@Corso = IntRate,
			@TableRate = TableRate,
			@SellingRate = SellingRate
		from  [Accounting].[tbl_CurrencyGamingdateRates]
		where CurrencyID = @CurrencyID  
		AND   GamingDate = 
		(
			SELECT  MAX(GamingDate)
			FROM [Accounting].[tbl_CurrencyGamingdateRates]
			where CurrencyID = @CurrencyID   
			AND GamingDate <= @GamingDate  
			AND IntRate is not NULL
			) 
		if @Corso is null
		begin
			declare @tmp varchar(128)
			set @tmp = 'Could not find any internal rate for currency ' + str(@CurrencyID)
			raiserror(@tmp,16,-1)
		end
		print 'Rate not found last known : ' + convert(varchar(32),@Corso) 
		set @IntRate = @Corso
		if not exists (select GamingDate from [Accounting].[tbl_CurrencyGamingdateRates]
			where CurrencyID = @CurrencyID  and GamingDate = @GamingDate)
		begin
	--		print 'inserted a new Internal rate for gaming date ' + convert(varchar(32),@GamingDate,113) 
			insert into [Accounting].[tbl_CurrencyGamingdateRates]
			(GamingDate,CurrencyID,IntRate,TableRate,FixedUserAccessID,FixedTime,SellingRate) 
			values(@GamingDate,@CurrencyID,@IntRate,@TableRate,@UserAccessID,GetUTCDate(),@SellingRate)
		end
		else
		begin
	--		print 'updating existing Internal rate for gaming date ' + convert(varchar(32),@GamingDate,113) 
			update [Accounting].[tbl_CurrencyGamingdateRates]
			set IntRate = @IntRate,
			FixedUserAccessID = @UserAccessID,
			FixedTime = GetUTCDate()
			where CurrencyID = @CurrencyID  and GamingDate = @GamingDate
			if @CurrencyID = 0 --Euros
				--fix also table and selling rate
				update [Accounting].[tbl_CurrencyGamingdateRates]
				set TableRate = @TableRate,SellingRate = @SellingRate
				where CurrencyID = @CurrencyID  and GamingDate = @GamingDate
		
		end
	end
	else
	begin
		set @IntRate = @Corso
		if exists 
		   (select GamingDate from [Accounting].[tbl_CurrencyGamingdateRates]
			where CurrencyID = @CurrencyID  
			AND GamingDate = @GamingDate 
			AND FixedUserAccessID is null)
		begin
			print 'fixing existing Internal rate ' + convert(varchar(32),@IntRate) + ' for gaming date ' + convert(varchar(32),@GamingDate,113) 
			update [Accounting].[tbl_CurrencyGamingdateRates]
				set FixedUserAccessID = @UserAccessID,
				FixedTime = GetUTCDate()
			where CurrencyID = @CurrencyID  
			AND GamingDate = @GamingDate 
		end
		else
			print 'found fixed existing Internal rate ' + convert(varchar(32),@IntRate) + ' for gaming date ' + convert(varchar(32),@GamingDate,113) 
	end


	COMMIT TRANSACTION trn_FixExchangeRate

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_FixExchangeRate
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
