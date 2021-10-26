SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [GoldenClub].[usp_MobileAppVerified]
@CardID 		INT,
@TimeStampLoc	DATETIME OUTPUT
AS

DECLARE @custid INT

select @custid = m.CustomerID 
FROM GoldenClub.tbl_Members m
INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = m.CustomerID 
WHERE m.GoldenClubCardID = @CardID and m.CancelID is NULL AND c.CustCancelID IS null

if @CustID is null or @cardid is null
BEGIN
	raiserror('Invalid CustomerID (%d) specified or Card is not part of GoldenClub or has already disclaimed',16,1,@CardID)
	RETURN (2)
END



set @TimeStampLoc = getutcdate()


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_MobileAppVerified

BEGIN TRY  

	UPDATE GoldenClub.tbl_Members
		SET StartUseMobileTimeStampUTC = @TimeStampLoc
	WHERE CustomerID = @CustID

	--return the @TimeStampLoc in local hour
	SET @TimeStampLoc=GeneralPurpose.fn_UTCToLocal(1,@TimeStampLoc)

	DECLARE @attribs VARCHAR(4096)
	SELECT @attribs = 
		'CustID=''' + CAST(@custid AS VARCHAR(32)) + '''' +
		' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' 
 
	EXECUTE [GeneralPurpose].[usp_BroadcastMessage] 'GCUseMobile',@attribs
	/*
	<MESS type='GCUseMobile' CustID='253' TransTimeLoc='xxxx'/>
	*/

	COMMIT TRANSACTION trn_MobileAppVerified

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_MobileAppVerified
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH


	--now call also dos app ClubVerified API
	DECLARE @errorMsg VARCHAR(1024);

	EXECUTE @ret = GeneralPurpose.usp_DOSGroup_ClubVerified @cardid,                    -- int
	                                                 1,               -- bit
	                                                 @errorMsg OUTPUT    -- varchar(1024)
	
RETURN @ret
GO
