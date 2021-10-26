SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Accounting].[usp_DRGTCashlessTransaction]
@Quantity int,	
@CardID char(16),
@LifeCycleID int,
@CashlessTransID int output,
@TransTime datetime output
AS

DECLARE @stockid int
if not exists (
select LifeCycleID from Accounting.tbl_LifeCycles 
inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.stockid
where LifeCycleID = @LifeCycleID 
and CasinoLayout.Stocks.StockTypeID in(4,7) -- cassa and main cassa only
)
begin
	raiserror('Invalid SourceLifeCycleID (%d) specified ',16,1,@LifeCycleID)
	return 1
end

SELECT @stockid = stockid FROM Accounting.tbl_LifeCycles where LifeCycleID = @LifeCycleID 

if @CardID is null or len(@CardID) <> 16
begin
	raiserror('Invalid CardID specified',16,1)
	return 2
end

--look in old stuff to check it is a valid card
IF NOT EXISTS 
( SELECT CardCode FROM OldStuff.cashless.tbl_CardPurses WHERE CARDCODE = RIGHT(@CardID,4) AND RedeemStockID IS null)
begin
	raiserror('Card %s not in the liability',16,1,@CardID)
	return 3
end

DECLARE @gamingdate datetime
declare @tag varchar(64)

select @gamingdate = Accounting.tbl_LifeCycles.GamingDate,
	@tag = CasinoLayout.Stocks.Tag
from Accounting.tbl_LifeCycles 
inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.stockid
where LifeCycleID = @LifeCycleID 

set @TransTime = GetUTCDate()

declare @ret int
set @ret = 0
BEGIN TRANSACTION trn_DRGTCashlessTrans

BEGIN TRY  

	--create a new customertransaction
	insert into Accounting.tbl_CashlessTransactions
	(	
		CardNumber,
		LifeCycleId,
		ImportoCents,
		TransTime
	)
	values(
		@CardID,
		@LifeCycleID,
		@Quantity,
		@TransTime
	)

	set @CashlessTransID = SCOPE_IDENTITY()
	set @TransTime = GeneralPurpose.fn_UTCToLocal(1,@TransTime)

	--if we started with the new DRGT system 
	--mark it has been redeemed
	UPDATE OldStuff.cashless.tbl_CardPurses 
	SET RedeemStockID = @stockid,RedeemTimeStampLocal = @TransTime
		WHERE CARDCODE = RIGHT(@CardID,4)
		
	COMMIT TRANSACTION trn_DRGTCashlessTrans
	-- return transaction time in local hour

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DRGTCashlessTrans		
	declare @dove as varchar(50)
	set @ret = ERROR_NUMBER()
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH
RETURN @ret
GO
