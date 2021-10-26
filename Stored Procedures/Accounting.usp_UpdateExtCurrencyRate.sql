SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Accounting].[usp_UpdateExtCurrencyRate]
@IncassoLFID 				INT,
@CurrencyID 				SMALLINT,
@ExtRate 					FLOAT,
@UserAccessID 				INT,
@IntRate 					FLOAT OUTPUT,
@TableRate 					FLOAT OUTPUT,
@SellingRate 				FLOAT OUTPUT,
@TrolleyGamingDate 			DATETIME OUTPUT,
@Fixed 						TINYINT OUTPUT,
@TaglioMin 					INT OUTPUT,
@ExchangeRateMultiplier		SMALLINT OUTPUT
AS

DECLARE		
@note				VARCHAR(1024),
@nStockTypeID		INT,
@IncassoGamingdate	DATETIME,
@Corso				FLOAT,
@FixedUserAccessID	INT,
@TimeStampUTC		datetime

set @Fixed = 0
set @TableRate = null
SET @note = NULL

select @IncassoGamingdate = GamingDate 
FROM Accounting.tbl_LifeCycles 
INNER JOIN CasinoLayout.Stocks ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
where LifeCycleID = @IncassoLFID
and CasinoLayout.Stocks.StockTypeID = 5 --incasso StockTypeID
if (@IncassoGamingdate is null) 
begin
	raiserror('Not a valid Incasso LifeCycleID Specified',16,-1)
	RETURN (1)
END

--incasso sets internal rate for the day after the external rate date 
set @TrolleyGamingDate = DateAdd(dd,1,@IncassoGamingdate)
----print 'TrolleyGamingdate is ' + convert(varchar(32),@TrolleyGamingdate,113)
--Check ValueTypeID parameter
if 	@CurrencyID is null  
	or not exists(
		select CurrencyID from CasinoLayout.tbl_Currencies 
		where  CurrencyID = @CurrencyID 
		and CurrencyID <> 4 --not chf		
		)
begin
	raiserror('Ivalid CurrencyID (%d): is a foreign currency!!',16,@CurrencyID)
	return (1)
END


select  
	@ExchangeRateMultiplier = cu.ExchangeRateMultiplier,
	@TaglioMin				= cu.BD0 --MinDenomination
from CasinoLayout.tbl_Currencies cu 
where  cu.CurrencyID = @CurrencyID

if @TaglioMin is null or @TaglioMin = 0
begin
	raiserror('Taglio minimo della currency %d non esiste!!',16,-1,@CurrencyID)
	RETURN (1)
END

--Check Rate parameter
if (@ExtRate is not null) and (
	(@ExtRate <= 0.0) or
	(@ExtRate > 1000.0))
begin
	raiserror('Must specify a valid External Rate',16,-1)
	RETURN (1)
END

--check if the record for trolley gaming date exists already 
--because an internal exchange rate has been set already

select 	
	@Corso					= IntRate, 
	@FixedUserAccessID		= FixedUserAccessID,
	@TableRate				= TableRate,
	@SellingRate			= SellingRate
from [Accounting].[tbl_CurrencyGamingdateRates]
where GamingDate = @TrolleyGamingdate AND CurrencyID = @CurrencyID

if @FixedUserAccessID is not null 
	set @Fixed = 1

declare @ret INT,@ValueTypeID int
set @ret = 0
SELECT @ValueTypeID = v.ValueTypeID 
FROM CasinoLayout.tbl_ValueTypes v
INNER JOIN CasinoLayout.tbl_Currencies c ON c.CurrencyID = v.CurrencyID
WHERE c.CurrencyID = @CurrencyID 
AND v.ValueTypeID IN(7,8,9,23,24,25,26,27,28)
if @tagliomin is null or @tagliomin = 0
begin
	raiserror('ValueTypeID not found for currency (%d)',16,-1,@CurrencyID)
	RETURN (1)
END

BEGIN TRANSACTION trn_UpdateExtExchangeRate

BEGIN TRY  

SET @TimeStampUTC = GETUTCDATE()

EXECUTE [Accounting].[usp_CalculateCurrencyRate] 
		@CurrencyID,
		@ExtRate,
		@IncassoGamingdate,
		@IntRate 			OUTPUT,
		@TableRate			OUTPUT,
		@SellingRate		OUTPUT,
		@note				OUTPUT

 if (@Corso is null or @Fixed = 0)
begin
	if(@Corso is null)
	begin
		--print 'Inserting [tbl_CurrencyGamingdateRates] internal rate ' + convert(varchar(32),@IntRate) + ' for day ' + convert(varchar(32),@TrolleyGamingDate,113)
		insert into [Accounting].[tbl_CurrencyGamingdateRates]
			(
				GamingDate,
				CurrencyID,
				IntRate,
				TableRate,
				SellingRate,
				Note,
				InsertTime,
				InsertUserAccessID
			) 
			VALUES
			(
				@TrolleyGamingDate,
				@CurrencyID,
				@IntRate,
				@TableRate,
				@SellingRate,
				@note,
				@TimeStampUTC,
				@UserAccessID
			)
	end
	ELSE
	BEGIN
		--print 'Updating ExchangeRates internal rate ' + convert(varchar(32),@IntRate) + ' for day ' + convert(varchar(32),@TrolleyGamingDate,113)
		UPDATE [Accounting].[tbl_CurrencyGamingdateRates]
			SET IntRate		= @IntRate,
				TableRate	= @TableRate,
				SellingRate = @SellingRate,
				Note		= @note,
				InsertTime	= @TimeStampUTC
			WHERE GamingDate=@TrolleyGamingDate AND CurrencyID = @CurrencyID

	END



	IF  @CurrencyID = 0 --in case of euros and internal rate has changed
		AND @note IS NOT NULL
 	BEGIN

		--PRINT	'Internal rate is ' + convert(varchar(32),@IntRate)

		DECLARE @body varchar(MAX)
		set	@body = N'<HTML><BODY bgColor=''cyan''>
		<CENTER><font color=#996666 size=28pt> Cambio Euro </font>
		<br>											
		<br>Data e Ora: ' + convert(nvarchar(16),GETDATE(),0) + '
		<br>											
		<br>GamingDate: ' + CONVERT(NVARCHAR(16),@TrolleyGamingdate,105) + '											
		<br>											
		<table bgcolor=#e4e4e4 border=1>
		<font color=''blue'' size=18pt>	
			<tr>
				<td width=360><left>Cambio Esterno</left></td>
				<td width=360><right>Cambio Interno</right></td>
				<td width=360><right>Note</rigth></td>
			</tr>		  
			<tr>		  
				<td><right>' + cast(@ExtRate as nvarchar(32)) + '</right></td>
				<td><right>' + cast(@IntRate as nvarchar(32)) + '</right></td>
				<td><right>' + @note + '</rigth></td>
			</tr>
		</font>
		</table>
		</CENTER></BODY></HTML>'


		EXEC	[GeneralPurpose].[usp_EmailMessage]
				@sub = @note,
				@bod = @body, --N'test del gruppo ramclear',
				@rec = N'ReportAlamo@casinomendrisio.ch',
				@from = 'sr-alamo@cmendrisio.office.ch'

	END --@EuroValueTypeID

END
ELSE IF (@Corso IS NOT NULL OR @Fixed = 1)
	--return current internal rate
	SET @IntRate = @Corso

--in any case we have to update the external rate for the incasso gaming date
--scale down the external exchange rate to 1 unit (ex: 1 YPN = 0.0066 SFr. and not 100 YPN = 0.66 Sfr)
set @ExtRate = @ExtRate / @ExchangeRateMultiplier


IF EXISTS (SELECT GamingDate FROM [Accounting].[tbl_CurrencyGamingdateRates]
			WHERE GamingDate = @IncassoGamingdate AND CurrencyID = @CurrencyID)
begin
	----print 'Updating ExchangeRates external rate '+ convert(varchar(32),@ExtRate) + ' for day ' + convert(varchar(32),@IncassoGamingdate,113)
	update [Accounting].[tbl_CurrencyGamingdateRates] 
	set 
			ExtRate				= @ExtRate,
			InsertUserAccessID	= @UserAccessID,
			InsertTime			= @TimeStampUTC
	where GamingDate=@IncassoGamingdate AND CurrencyID = @CurrencyID


END
ELSE
BEGIN
	----print 'Inserting ExchangeRates external rate '+ convert(varchar(32),@ExtRate) + ' for day ' + convert(varchar(32),@IncassoGamingdate,113)
	INSERT INTO [Accounting].[tbl_CurrencyGamingdateRates] 
	(
		GamingDate,
		CurrencyID,
		IntRate,
		ExtRate,
		SellingRate,
		InsertUserAccessID,
		InsertTime
	)
	VALUES
	(
		@IncassoGamingdate,
		@CurrencyID,
		@IntRate,
		@ExtRate,
		@SellingRate,
		@UserAccessID,
		@TimeStampUTC
	)


END

	COMMIT TRANSACTION trn_UpdateExtExchangeRate


END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_UpdateExtExchangeRate	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
	RETURN @ret
END CATCH

	--broadcast change of currency rate
	DECLARE @attribs varchar(4096)
	SELECT @attribs = 
	'Currency=''' + CAST(@CurrencyID as varchar(32)) + '''' +
	' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TrolleyGamingDate) + '''' +
	' ExchangRate=''' + CAST(@IntRate as varchar(32)) + '''' +
	' TimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](GeneralPurpose.fn_UTCToLocal(1,@TimeStampUTC)) + '''' 
	--print @attribs
	EXECUTE [GeneralPurpose].[usp_BroadcastMessage] 'ExchangeRate',@attribs

IF  @CurrencyID = 0 --in case of euros
BEGIN
	--update also GASTRO database
	--select * from [Gastro].[TCPOS4].[dbo].[currency_rates]
	EXECUTE [GASTRO].[GastroHelper].[Accounting].[usp_EnterEuroRate] @IntRate

	--update also dgt database
	EXECUTE [DRGT].[drMenhelper].[Accounting].[usp_UpdateEuroRate] @TrolleyGamingDate,@IntRate

END



RETURN 0
GO
