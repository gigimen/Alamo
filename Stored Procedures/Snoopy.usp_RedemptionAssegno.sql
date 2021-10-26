SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Snoopy].[usp_RedemptionAssegno]
@AssegnoID int,
@UserAccessID int,
@CustTransID int output,
@CustTransTime datetime output,
@TotRedeemed float output
AS



--get the Customer ID from incasso Assegno
declare @CustID int
declare @SourceLifeCycleID int
declare @Quantity int
declare @GamingDate datetime

--source lifecycle must be the same as the incasso assegno
select  
	@CustID = CustomerID,
	@GamingDate = GamingDate,
	@Quantity = CHF,
	@SourceLifeCycleID = EmissLFID
from Snoopy.vw_AllAssegni
Where AssegnoID = @AssegnoID and RedemCustTransID is null


IF @AssegnoID is NULL
begin
	raiserror('NULL AssegnoID specified ',16,1)
	return 1
END

--first some check on parameters
if @CustID is null or @SourceLifeCycleID is null
begin
	raiserror('Invalid AssegnoID (%d) specified ',16,1,@AssegnoID)
	return 1
end

if not exists (
select LifeCycleID from Accounting.tbl_LifeCycles 
inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
where LifeCycleID = @SourceLifeCycleID 
and CasinoLayout.Stocks.StockTypeID in(4,7) -- cassa and main cassa only
)
begin
	raiserror('Invalid SourceLifeCycleID (%d) specified ',16,1,@SourceLifeCycleID)
	return 1
end
if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	return 1
end

--RETURN HOW MANY ASSEGNI REDEMPTION SO FAR TODAY FOR THIS CUSTOMER
select @TotRedeemed = sum(CHF)
from Snoopy.vw_AllAssegni
where CustomerID = @CustID
and GamingDate = (SELECT GamingDate FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @SourceLifeCycleID)
and RedemCustTransID is not null

if @TotRedeemed is null
	set @TotRedeemed = 0

set @CustTransTime = GetUTCDate()

--create a new customertransaction
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_RedemptionAssegno

BEGIN TRY  




	insert into Snoopy.tbl_CustomerTransactions
	(
		OpTypeID,
		CustomerTransactionTime,
		SourceLifeCycleID,
		CustomerID,
		UserAccessID
	)
	values(
		9, --Assegno
		@CustTransTime,
		@SourceLifeCycleID,
		@CustID,
		@UserAccessID)

	set @CustTransID = SCOPE_IDENTITY()


	--add the new Quantity just redeemed
	set @TotRedeemed = @TotRedeemed + @Quantity

	--finally set it into Assegni Table
	update Snoopy.tbl_Assegni
	set FK_RedemCustTransID = @CustTransID
	where PK_AssegnoID = @AssegnoID

	-- return cust transaction time in local hour
	set @CustTransTime = GeneralPurpose.fn_UTCToLocal(1,@CustTransTime)



	COMMIT TRANSACTION trn_RedemptionAssegno

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RedemptionAssegno
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
