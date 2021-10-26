SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Marketing].[usp_AssegnaNuovoPremio]
@CustID 			INT,
@SectorID			INT,
@SiteID				INT,
@OffertaPremioID	int,
@UserID				INT,
@Multiplo			INT,
@Comment			varchar(1024),
@TimeStampLoc		DATETIME OUTPUT,
@AssegnazionePremioID INT	OUTPUT
AS
---
--check input values
if @CustID is null or not exists (select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID and [CustCancelID] is null)
begin
	raiserror('Invalid CustomerID (%d) specified ',16,1,@CustID)
	return (1)
end
if @Multiplo is null or @Multiplo <= 0
begin
	raiserror('Invalid @Multiplo specified',16,1)
	return (1)
end

if @SiteID is null or not exists (select SiteID from CasinoLayout.Sites where SiteID = @SiteID)
begin
	raiserror('Invalid SiteID (%d)',16,1,@SiteID)
	return (3)
END
if @UserID is null or not exists (select UserID from CasinoLayout.Users where UserID = @UserID)
begin
	raiserror('Invalid UserID (%d)',16,1,@UserID)
	return (3)
END


IF NOT EXISTS (select OffertaPremioID from Marketing.tbl_OffertaPremi where OffertaPremioID = @OffertaPremioID)   
begin
	raiserror('Invalid @OffertaPremioID (%d)',16,1,@OffertaPremioID)
	return (3)
END
DECLARE @assSectorID INT,@ritSiteID INT,@ritTimeStampUTC datetime, @ritGamingDate DATETIME ,@ret int

--get the @assSectorID from the UserID
--per i buoni cena e pasta drink
if exists (SELECT [OffertaPremioID] FROM [Marketing].[tbl_OffertaPremi] where @OffertaPremioID = OffertaPremioID and PromotionID = 19)
begin
	select @assSectorID = SectorID from [CasinoLayout].[UserGroup_User] where UserID = @UserID AND SectorID IS NOT null
	if @assSectorID is null 
	begin
		raiserror('UserID (%d) has no sector assigned. chiamare GIGI!!',16,1,@UserID)
		return (3)
	END
end

set @TimeStampLoc = getutcdate()

set @ret = 0

IF @OffertaPremioID IN (101,102) --buoni macdonald e lucky chips
BEGIN
	SET @ritSiteID			= @SiteID
	SET @ritTimeStampUTC	= @TimeStampLoc
	SET @ritGamingDate		= GeneralPurpose.fn_GetGamingDate(@TimeStampLoc,1,7)
END
ELSE
BEGIN
	SET @ritSiteID			= NULL
	SET @ritTimeStampUTC	= NULL
	SET @ritGamingDate		= NULL
END


BEGIN TRANSACTION trn_AssegnaNuovoPremio

BEGIN TRY  


	--piazza l'ordine
	INSERT INTO Marketing.tbl_AssegnazionePremi
	(
	    OffertaPremioID,
	    CustomerID,
	    InsertTimeStampUTC,
	    RitiratoTimeStampUTC,
	    InsertSiteID,
	    RitiroSiteID,
	    InsertUserID,
	    Multiplo,
	    AssigningSectorID,
		[RitiratoGamingDate]
	)
	VALUES
	(
		@OffertaPremioID,
		@CustID,
		@TimeStampLoc,
		@ritTimeStampUTC,
		@SiteID,
		@ritSiteID,
		@UserID,
		@Multiplo,
		@assSectorID,
		@ritGamingDate
	)


	set @AssegnazionePremioID = SCOPE_IDENTITY()
	
	set	@TimeStampLoc = GeneralPurpose.fn_UTCToLocal(1,@TimeStampLoc)


	IF @Comment IS NOT NULL
    BEGIN
		IF LEN(@Comment) > 0
			UPDATE Snoopy.tbl_Customers SET Comment = @Comment where CustomerID = @CustID
		else
			UPDATE Snoopy.tbl_Customers SET Comment = null where CustomerID = @CustID
	END
    
	--infine aggiorna il settore nel caso 
	IF @SectorID IS NOT NULL AND EXISTS (SELECT CustomerId FROM Snoopy.tbl_Customers WHERE CustomerID = @CustID AND SectorID IS null) 
	BEGIN
			UPDATE Snoopy.tbl_Customers 
				SET SectorID = @SectorID
			WHERE CustomerID = @CustID
	END

	COMMIT TRANSACTION trn_AssegnaNuovoPremio

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_AssegnaNuovoPremio
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
