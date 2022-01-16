SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE  PROCEDURE [Snoopy].[usp_Ingresso_VetoControl] 
@controlString		VARCHAR(50),
@SiteID 			INT,
@hitsNumber			INT,
@UserID				INT,
@fk_controlid		INT output
AS


if not exists (select SiteID
FROM    CasinoLayout.Sites
where SiteID = @SiteID)
begin
	raiserror('Invalid SiteID (%d) specified',16,1,@SiteID)
	RETURN (1)
END

if not exists (select UserID
FROM    CasinoLayout.Users
where UserID = @UserID)
begin
	raiserror('Invalid UserID (%d) specified',16,1,@UserID)
	RETURN (4)
END

IF @hitsNumber IS NULL
BEGIN
	raiserror('Invalid null hitsNumber specified',16,1)
	return (2)
END

IF @controlString IS NULL OR LEN(@controlString) = 0
BEGIN
	RAISERROR('Invalid null controlString specified',16,1)
	RETURN (3)
END

DECLARE 
@TimeStampUTC DATETIME, 
@TimeStampLoc DATETIME, 
@gaming			DATETIME,
@ret			INT

SET @TimeStampUTC = GETUTCDATE()
SET @TimeStampLoc = GETDATE()
SET @Gaming = [GeneralPurpose].[fn_GetGamingDate](@TimeStampUTC,1,DEFAULT)

BEGIN TRANSACTION trn_VetoControl

BEGIN TRY  


	INSERT INTO Reception.tbl_VetoControls
			   ([searchString]
			   ,[HitsNumber]
			   ,[SiteId]
			   ,[UserID])
	VALUES
	(
		@controlString,
		@HitsNumber,
		@SiteID,
		@UserID
	)

	SET @fk_controlid = SCOPE_IDENTITY()

	COMMIT TRANSACTION trn_VetoControl

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_VetoControl
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
