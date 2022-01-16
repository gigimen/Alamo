SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [Snoopy].[usp_TorneoPoker_Vincita]
@CustID						INT,
@FK_TPGiornataID			INT ,
@LifeCycleID				INT,
@UserAccessID				INT,
@AmountCents				INT,
@MoveType					INT,
@PK_MovID					INT OUTPUT,
@NrProgressivo				INT OUTPUT,
@TimeStampUTC				DATETIME OUTPUT
AS
--first some check on parameters
IF NOT EXISTS(SELECT CustomerID FROM Snoopy.tbl_Customers WHERE CustomerID = @CustID AND CustCancelID IS NULL)
BEGIN
	RAISERROR('Invalid CustomerID (%d) specified ',16,1,@CustID)
	RETURN 1
END

IF @AmountCents IS NULL OR @AmountCents = 0 
BEGIN
	RAISERROR('Invalid @AmountCents specified',16,1)
	RETURN 1
END

--controllo max rientri



DECLARE @GamingDate DATETIME
DECLARE @Tag VARCHAR(64)
DECLARE @ret INT,@dayTypeID INT


IF not exists (
	select LifeCycleID from Accounting.tbl_LifeCycles 
	inner join CasinoLayout.Stocks on Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
	where LifeCycleID = @LifeCycleID 
	and CasinoLayout.Stocks.StockTypeID in(4,7) -- cassa and main cassa only
	)
begin
	raiserror('Invalid LifeCycleID (%d) specified ',16,1,@LifeCycleID)
	RETURN 1
END

IF @MoveType NOT IN (1,2)
begin
	raiserror('Invalid @MoveType (%d) specified only (1,2) allowed!!',16,1,@MoveType)
	RETURN 1
END

--get gaming date and Tag from LifeCles table
SELECT 
	@GamingDate = Accounting.tbl_LifeCycles.GamingDate,
	@Tag = CasinoLayout.Stocks.Tag
FROM Accounting.tbl_LifeCycles 
INNER JOIN CasinoLayout.Stocks ON Accounting.tbl_LifeCycles.StockID = CasinoLayout.Stocks.StockID
WHERE LifeCycleID = @LifeCycleID 


if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	RETURN 1
END


SELECT @dayTypeID = [FK_DayTypeID]
  FROM [CasinoLayout].[tbl_TorneiPokerGiornate]
  WHERE [PK_TPGiornataID] = @FK_TPGiornataID

IF @dayTypeID IS NULL
begin
	raiserror('Invalid @FK_TPGiornataID specified ',16,1)
	RETURN 1
END

SELECT @NrProgressivo = MAX(Progressivo) FROM [Snoopy].[tbl_PokerTorneoCashMov]
WHERE FK_TPGiornataID = @FK_TPGiornataID

IF @NrProgressivo IS NULL AND @dayTypeID IN(1,2) 
--nessun iscritto al satellite e day1!! 
--non si possonopagare le vencite per questi giorni se non ci sono iscritti
begin
	raiserror('Cannot be neanche un iscritto!!',16,1)
	RETURN 1
END

IF @NrProgressivo IS NULL
	SET @NrProgressivo = 0

SET @NrProgressivo += 1

SET @ret = 0

BEGIN TRANSACTION trn_TorneoPokerVincita

BEGIN TRY  

	SET @TimeStampUTC = GETUTCDATE()

	INSERT INTO [Snoopy].[tbl_PokerTorneoCashMov]
			   ([FK_TPGiornataID]
			   ,[FK_LIfeCyleID]
			   ,[MoveType]
			   ,[TimeStampUTC]
			   ,[AmountCents]
			   ,[FK_CustomerID]
			   ,FK_UserAccessID
			   ,Progressivo)
		 VALUES
			   (@FK_TPGiornataID
			   ,@LifeCycleID
			   ,@MoveType --rotto or Vincita 
			   ,@TimeStampUTC
			   ,@AmountCents
			   ,@CustID
			   ,@UserAccessID
			   ,@NrProgressivo)

	SET @PK_MovID = SCOPE_IDENTITY()

		
	COMMIT TRANSACTION trn_TorneoPokerVincita

	-- return cust transaction time in local hour
	SET @TimeStampUTC = GeneralPurpose.fn_UTCToLocal(1,@TimeStampUTC)


END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_TorneoPokerVincita
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
