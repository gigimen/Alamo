SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Snoopy].[usp_AssegniControlloAssegno]
@AssegnoID INT,
@UserAccessID INT,
@controlDate DATETIME,
@controlTimeLoc	DATETIME OUT
AS


--first some check on parameters
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specifie',16,1,@UserAccessID)
	RETURN 1
END



IF NOT EXISTS (SELECT AssegnoID 
	FROM Snoopy.vw_AllAssegniEx 
	WHERE AssegnoID = @AssegnoID AND RedemCustTransID IS null)
BEGIN
	RAISERROR('Assegno %d is redeemed!',16,1,@AssegnoID)
	RETURN 1
END


--assegno is not controlled yet but we did not specify a control date
IF EXISTS (SELECT PK_AssegnoID 
		FROM Snoopy.[tbl_Assegni] 
		WHERE PK_AssegnoID = @AssegnoID AND [FK_RedemCustTransID] IS NULL AND [ControlDate] IS null)
AND @controlDate IS NULL
begin
	raiserror('NULL @controlDate specified',16,1)
	RETURN 1
END
DECLARE @ret INT
SET @ret = 0

BEGIN TRANSACTION trn_ControlloAssegno

BEGIN TRY  

	IF EXISTS (SELECT PK_AssegnoID 
		FROM Snoopy.[tbl_Assegni] 
		WHERE PK_AssegnoID = @AssegnoID AND [FK_RedemCustTransID] IS NULL AND [ControlDate] IS NOT null)
	BEGIN
		--assegno is controlled : delete control information
		UPDATE [Snoopy].[tbl_Assegni]
		   SET [FK_ControlUserAccessID] = NULL
			  ,[ControlTimeStampUTC] = NULL
			  ,[ControlDate] = NULL
		 WHERE PK_AssegnoID = @AssegnoID

		 SET @controlTimeLoc = NULL
	END
	ELSE
	BEGIN
		--mark assegno controlled
		SET @controlTimeLoc = GETUTCDATE()
		UPDATE [Snoopy].[tbl_Assegni]
		   SET [FK_ControlUserAccessID] = @UserAccessID
			  ,[ControlTimeStampUTC] = @controlTimeLoc
			  ,[ControlDate] = @controlDate
		 WHERE PK_AssegnoID = @AssegnoID

		SET @controlTimeLoc = GeneralPurpose.fn_UTCToLocal(1,@controlTimeLoc)
	END
	COMMIT TRANSACTION trn_ControlloAssegno

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_ControlloAssegno
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

RETURN @ret
GO
