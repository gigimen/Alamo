SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [Snoopy].[usp_Assegni_RedemptionAssegno]
@AssegnoID INT,
@UserAccessID INT,
@CustTransID INT OUTPUT,
@CustTransTime DATETIME OUTPUT,
@TotRedeemed FLOAT OUTPUT
AS



--get the Customer ID from incasso Assegno
declare @CustID int
declare @SourceLifeCycleID int
declare @Quantity int
declare @GamingDate datetime

--source lifecycle must be the same as the incasso assegno
select  @CustID = CustomerID,
	@GamingDate = GamingDate,
	@Quantity = CHF,
	@SourceLifeCycleID = EmissLFID
from Snoopy.vw_AllAssegniEx
Where AssegnoID = @AssegnoID and RedemCustTransID is null


IF @AssegnoID is NULL
begin
	raiserror('NULL AssegnoID specified ',16,1)
	RETURN 1
END

--first some check on parameters
if @CustID is null or @SourceLifeCycleID is null
begin
	raiserror('Invalid AssegnoID (%d) specified ',16,1,@AssegnoID)
	RETURN 1
END

if not exists (
select LifeCycleID from Accounting.tbl_LifeCycles 
inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
where LifeCycleID = @SourceLifeCycleID 
and CasinoLayout.Stocks.StockTypeID in(4,7) -- cassa and main cassa only
)
begin
	raiserror('Invalid SourceLifeCycleID (%d) specified ',16,1,@SourceLifeCycleID)
	RETURN 1
END
if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	RETURN 1
END

--RETURN HOW MANY ASSEGNI REDEMPTION SO FAR TODAY FOR THIS CUSTOMER
select @TotRedeemed = sum(CHF)
from Snoopy.vw_AllAssegniEx
where CustomerID = @CustID
and GamingDate = (SELECT GamingDate FROM Accounting.tbl_LifeCycles WHERE LifeCycleID = @SourceLifeCycleID)
and RedemCustTransID is not null

if @TotRedeemed is null
	set @TotRedeemed = 0

set @CustTransTime = GetUTCDate()

--create a new customertransaction
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_RedemptionAssegnoEx

BEGIN TRY  




	INSERT INTO Snoopy.tbl_CustomerTransactions
	(
		OpTypeID,
		CustomerTransactionTime,
		SourceLifeCycleID,
		CustomerID,
		UserAccessID
	)
	VALUES(
		9, --Assegno
		@CustTransTime,
		@SourceLifeCycleID,
		@CustID,
		@UserAccessID)

	SET @CustTransID = SCOPE_IDENTITY()


	--add the new Quantity just redeemed
	SET @TotRedeemed = @TotRedeemed + @Quantity

	--finally set it into Assegni Table
	UPDATE Snoopy.tbl_Assegni
	SET FK_RedemCustTransID = @CustTransID
	WHERE PK_AssegnoID = @AssegnoID

	-- return cust transaction time in local hour
	SET @CustTransTime = GeneralPurpose.fn_UTCToLocal(1,@CustTransTime)



	COMMIT TRANSACTION trn_RedemptionAssegnoEx

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RedemptionAssegnoEx
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
