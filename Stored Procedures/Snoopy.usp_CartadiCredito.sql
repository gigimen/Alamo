SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Snoopy].[usp_CartadiCredito] 
@LifeCycleID				int,
@ImportoCents				int,
@DenoID						int,
@Commissione			    FLOAT,
@ContropartitaID			int,
@ExchangeRate				float,
@IDDocID 					int,
@UserAccessID 				int,
@EuroTransactionID			INT output,
@goldenclubcustid			INT output,
@GoldenclubCardID			int output,
@euroNettiCents				INT output,
@MovimentoGettoniGiocoEuroID INT output,
@sfrNettiCents				INT output,
@CreditCardTransID 			int output,
@TransTime 					datetime output,
@TotCHFCents				int output,
@deleteMe					int
AS

if @CreditCardTransID is not null and @CreditCardTransID > 0
begin
	if @LifeCycleID is not null and not exists (select LifeCycleID from Accounting.vw_AllCartediCredito where CreditCardTransID = @CreditCardTransID
	and LifeCycleID = @LifeCycleID)
	begin
		raiserror('Cannot specify a different LifeCycleID if CreditCardTransID(%d) is specified',16,1,@CreditCardTransID)
		return 1
	end
	select @LifeCycleID = LifeCycleID from Accounting.vw_AllCartediCredito where CreditCardTransID = @CreditCardTransID
	if @TransTime is not null
		--tranform it in UTC
		exec @TransTime = GeneralPurpose.fn_UTCToLocal 0,@TransTime

end

if @deleteMe is null OR  @deleteMe = 0
BEGIN
	IF NOT exists (select LifeCycleID from Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID )
	begin
		raiserror('Invalid LifeCycleID specified (%d)',16,1,@LifeCycleID)
		return 1
	END
    

	IF @ImportoCents IS NULL OR @ImportoCents = 0
	BEGIN
		raiserror('Invalid @ImportoCents specified',16,1)
		return 1
	END
    
end



--STORE HOW MANY CC SO FAR TODAY FOR THIS LIFE CYCLE
select @TotCHFCents = isnull(sum(CHF),0) * 100
from Accounting.vw_AllCartediCredito
where LifeCycleID = @LifeCycleID


declare 
	@custid INT,
	@custTransid INT,
	@LeftTobeRedeemedCents INT,
	@denomination FLOAT

select @denomination = Denomination 
from CasinoLayout.tbl_Denominations where DenoID = @denoid

SET @goldenclubcustid = NULL
SET @LeftTobeRedeemedCents = NULL


/*run some inout parameter checks*/
if @deleteMe is not null and @deleteMe <> 0
begin
	if @CreditCardTransID is null
	begin
		raiserror('NULL CreditCardTransID specified ',16,1)
		return 1
	end
end
else
begin
	
	--first some check on parameters
	if @ImportoCents is null or @ImportoCents = 0
	begin
		raiserror('Invalid @ImportoCents specified',16,1)
		return 1
	end
	



	select @custid = CustomerID from Snoopy.tbl_IDDocuments where IDDocumentID = @IDDocID
	if @custid is null 
	begin
		raiserror('Invalid IdDocID (%d) specified',16,1,@IDDocID)
		return 1
	end

	
	if @DenoID not in (
			90, --CC in SFr Globalcash
			174 --CC in € Aduno
			)
	begin
		raiserror('Denomination (%d) can only be Globalcash in Sfr or Aduno in €',16,1,@DenoID)
		return 1
	END
    
 	IF @DenoID in (
			174 --CC in € Aduno
			)
	BEGIN
		--make sure we do not provide a valid euro vendita transaction id 
		IF @EuroTransactionID  IS NOT null
		begin
			raiserror('Cannot specify € transaction ID (%d)',16,1,@EuroTransactionID)
			return 1
		end
		IF @MovimentoGettoniGiocoEuroID  IS NOT null
		begin
			raiserror('Cannot specify @MovimentoGettoniGiocoEuroID (%d)',16,1,@MovimentoGettoniGiocoEuroID)
			return 1
		end
		--in case of aduno we must specify the @Commissione parameter
		IF @Commissione IS NULL
        BEGIN
 			raiserror('Must specify the @Commissione parameter',16,1)
			return 1
       END
		--check it is a goldenclub member
		select @goldenclubcustid=CustomerID,@GoldenclubCardID = GoldenClubCardID from GoldenClub.tbl_Members 
		WHERE CustomerID = @custID and CancelID is null and GoldenClubCardID is not NULL
	
		--make sure we provide a valid contropartita
		IF NOT EXISTS (
			SELECT ContropartitaID 
			FROM CasinoLayout.tbl_Contropartite 
			WHERE ContropartitaID = @ContropartitaID 
			)  
		begin
			raiserror('Invalid @ContropartitaID specified',16,1)
			return 1
		END
        
	end
	
	if not exists (
	select LifeCycleID from Accounting.tbl_LifeCycles 
	inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.stockid
	where LifeCycleID = @LifeCycleID 
	and CasinoLayout.Stocks.StockTypeID in(4,7) -- cassa and main cassa only
	)
	begin
		raiserror('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
		return 1
	end

end

--calculate chf netti and euro netti

set @euroNettiCents = CEILING(@importocents / ( 1 + @Commissione));
SET @sfrNettiCents = CEILING(@euroNettiCents * @exchangerate);



--we will allow to redeem @euroNettiCents
IF @goldenclubcustid IS NOT NULL 
	SET @LeftTobeRedeemedCents = @euroNettiCents


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_RegisterCartadiCredito

BEGIN TRY  




	if @deleteMe is not null and @deleteMe <> 0
	begin
		--detract old value
		set @TotCHFCents = @TotCHFCents - (select CHF * 100 from Accounting.vw_AllCartediCredito where CreditCardTransID = @CreditCardTransID)

		select 	@custTransid = FK_CustomerTransactionID
		from Snoopy.tbl_CartediCredito 
		where CreditCardTransID = @CreditCardTransID

		EXECUTE Snoopy.usp_DeleteCustomerTransaction @custTransid,@UserAccessID


		--remove possible euro transactions and gettoni gioco euro recording
		SELECT @MovimentoGettoniGiocoEuroID = FK_MovimentoGettoniGiocoEuroID,
		@EuroTransactionID= FK_EuroTransactionID FROM Snoopy.tbl_CartediCredito
		WHERE CreditCardTransID = @CreditCardTransID


		UPDATE Snoopy.tbl_CartediCredito
		SET FK_MovimentoGettoniGiocoEuroID = NULL,
		FK_EuroTransactionID = NULL 
		WHERE CreditCardTransID = @CreditCardTransID

		DELETE FROM Accounting.tbl_MovimentiGettoniGiocoEuro WHERE TransactionID = @MovimentoGettoniGiocoEuroID

		DELETE FROM Accounting.tbl_EuroTransactions WHERE TransactionID = @EuroTransactionID


	end
	else
	begin

		if @CreditCardTransID is null or @CreditCardTransID = 0 -- we have to create a new CC transaction
		begin
			set @TransTime = GetUTCDate()

 			IF @DenoID in (
					174 --CC in € Aduno
					)
			BEGIN
				IF @ContropartitaID IN(3,5) --we are buying CHF valuta or gettoni 
				BEGIN
					--we have to record a new Euro Transaction to give possibility to redeem the euro netti acquistati
					insert into Accounting.tbl_EuroTransactions
					(
						LifeCycleID,
						OpTypeID,
						ImportoEuroCents,
						ExchangeRate,
						FrancsInRedemCents,
						PhysicalEuros,
						CustomerID,
						LeftToBeRedeemedCents,
						InsertTimestamp,
						UserAccessID
					)
					values(
						@LifeCycleID,
						11,--acquisto euro
						@euroNettiCents,
						@ExchangeRate,
						null,
						0,--@PhysicalEuros,
						@goldenclubcustid,
						@LeftTobeRedeemedCents,
						@TransTime,
						@UserAccessID
						)

				set @EuroTransactionID = SCOPE_IDENTITY()
				END
				ELSE IF @ContropartitaID IN(4) --gettoni gioco euro
				BEGIN
 					--we have to record a new Euro Transaction
					INSERT INTO [Accounting].[tbl_MovimentiGettoniGiocoEuro]
						   ([LifeCycleID]
						   ,[DenoID]
						   ,[TotGettoni]
						   ,[ExchangeRate]
						   ,[ExchangeTimeUTC]
						   ,[CausaleID])
					values(
						@LifeCycleID,
						183,--DENOID_CAMBIO_CHF_TO_EUR: escono gettoni CHF entrano EUR
						CEILING(@sfrNettiCents / 100), --we acquire this quantiti of gettoni gioco euro
						@ExchangeRate,
						@TransTime,
						3 -- Acquisto gettoni € con Carta di credito
						)

				set @MovimentoGettoniGiocoEuroID = SCOPE_IDENTITY()
			   END
            
			END
            
			--create a new customertransaction
																	insert into Snoopy.tbl_CustomerTransactions
			(
				OpTypeID,
				CustomerTransactionTime,
				SourceLifeCycleID,
				CustomerID,
				UserAccessID
			)
			values(
				10, --Carta di credito
				@TransTime,
				@LifeCycleID,
				@custid,
				@UserAccessID
				)
				

			set @CustTransID = SCOPE_IDENTITY()
		
			--store cc importo
			insert into Snoopy.tbl_CustomerTransactionValues
			(
				DenoID,
				CustomerTransactionID,
				Quantity,
				ExchangeRate,
				CashInbound
			)
			values(
				@denoid,
				@CustTransID,
				@ImportoCents,
				@ExchangeRate,
				0
				)
			
	
			--finally store the carta di credito transaction
			INSERT INTO [Snoopy].[tbl_CartediCredito]
					   ([FK_IDDocumentID]
					   ,[FK_CustomerTransactionID]
					   ,[FK_EuroTransactionID]
					   ,[FK_MovimentoGettoniGiocoEuroID]
					   ,[Commissione]
					   ,[FK_ContropartitaID])
			values
			(
				@iddocid,
				@CustTransID,
				@EuroTransactionID,
				@MovimentoGettoniGiocoEuroID,
				@Commissione,
				@ContropartitaID
			)

			set @CreditCardTransID = SCOPE_IDENTITY()
		

		
			--return time in local time
			exec @TransTime = GeneralPurpose.fn_UTCToLocal 1,@TransTime
	
			--now return the total amount of CC for that LifeCycle
			--add the new CC transaction just registered
			set @TotCHFCents =  (@TotCHFCents + @ImportoCents * @denomination * @ExchangeRate * 100)
	
		end
		else -- we have to update specified transaction
		BEGIN

			DECLARE @OldQuantity INT,@OldExrate float
			--detract old value
			set @TotCHFCents = @TotCHFCents - (select CHF *100 from Accounting.vw_AllCartediCredito where CreditCardTransID = @CreditCardTransID)
	
			--time is already in local 
			select 	
				@CustTransID		= CustomerTransactionID,
				@OldQuantity		= Quantity,
				@OldExrate			= ExchangeRate,
				@EuroTransactionID	= EuroTransactionID,
				@MovimentoGettoniGiocoEuroID = MovimentoGettoniGiocoEuroID
			from  Accounting.vw_AllCartediCredito
			where CreditCardTransID = @CreditCardTransID
	
			update [Snoopy].[tbl_CartediCredito]
			--
			--update information on document used and type od transaction
			set FK_IDDocumentID			= @IDDocID,
				Commissione				= @Commissione,
				FK_ContropartitaID		= @ContropartitaID
			where CreditCardTransID		= @CreditCardTransID
	
			
		
			--update valore 
			update Snoopy.tbl_CustomerTransactionValues
			set DenoID			= @denoid,
				Quantity		= @ImportoCents,
				ExchangeRate	= @ExchangeRate
			where CustomerTransactionID = @CustTransID
 			

			--update ora 
			update Snoopy.tbl_CustomerTransactions
			set [CustomerTransactionTime] = @TransTime
			where CustomerTransactionID = @CustTransID
			
	
			--now return the total amount of CC for that LifeCycle
			--add the new CC transaction just registered
			set @TotCHFCents =  (@TotCHFCents + @ImportoCents * @denomination * @ExchangeRate * 100)

			--update also related euro transaction
			if @EuroTransactionID IS NOT null
				update Accounting.tbl_EuroTransactions
					set		ImportoEuroCents=@euroNettiCents,LeftToBeRedeemedCents=@euroNettiCents
				WHERE [TransactionID] = @EuroTransactionID

			--update also related @MovimentoGettoniGiocoEuroID
			if @MovimentoGettoniGiocoEuroID IS NOT null
				UPDATE [Accounting].[tbl_MovimentiGettoniGiocoEuro]
					SET [TotGettoni] = CEILING(@sfrNettiCents / 100)
				WHERE [TransactionID] = @MovimentoGettoniGiocoEuroID

			--insert a new entry in [FloorActivity].[CustomerTransactionModifications] to record the change of value
			INSERT INTO FloorActivity.tbl_CustomerTransactionModifications
					(UserAccessID
					,[CustomerTransactionID]
					,[DenoID]
					,CashInbound
					,[FromQuantity]
					,[ToQuantity]
					,[ExchangeRate])
			VALUES
					(
					@UserAccessID,
					@CustTransID,
					@denoid, 
					0,
					@OldQuantity,
					@ImportoCents,
					@OldExrate
					)
			
		end


	end

	COMMIT TRANSACTION trn_RegisterCartadiCredito

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RegisterCartadiCredito
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
