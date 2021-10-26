SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO




CREATE  PROCEDURE [Snoopy].[usp_IngressoRecordFasciaEta] 
@fk_controlid		INT,
@fasciaeta			INT,
@sesso				BIT,
@proveninenza		INT
AS

DECLARE  @ret			INT,
@attribs varchar(4096)

BEGIN TRANSACTION trn_IngressoRecordFasciaEta

BEGIN TRY  


	INSERT INTO Snoopy.tbl_FasceEtaRegistrations
			   ([FK_ControlID]
			   ,[FasciaEtaID]
			   ,Sesso
			   ,ProvenienzaID)
     VALUES
         (@fk_controlid,@fasciaeta,@sesso,@proveninenza)


	COMMIT TRANSACTION trn_IngressoRecordFasciaEta

	DECLARE @sitename VARCHAR(32),@SiteId INT

	SELECT @SiteID = s.SiteID,@sitename = s.FName
	FROM Snoopy.tbl_VetoControls c
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteId
	WHERE PK_ControllID = @fk_controlid AND s.SiteTypeID = 2 --only for sesam entrance

	IF @SiteId IS NOT NULL
	BEGIN
		DECLARE @TimeStampUTC DATETIME
		DECLARE @TimeStampLoc DATETIME
		DECLARE @gaming		  DATETIME

		SET @TimeStampUTC = GETUTCDATE()
		SET @TimeStampLoc = GETDATE()
		SET @Gaming = [GeneralPurpose].[fn_GetGamingLocalDate2](@TimeStampLoc,0,22) --change at 10 am for Veto position
		SELECT @attribs = 
			'SiteID=''' 		+ CAST(@SiteID AS VARCHAR(32)) + '''' +
			' SiteName=''' 		+ @SiteName + '''' +
			' GamingDate='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@Gaming) + '''' +
			' TransTimeLoc='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' +
			' CustID=''-3''' + 
			' Visite = ''1'''  

		EXECUTE [GeneralPurpose].[usp_BroadcastMessage] 'EntrataCK',@attribs
	END

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_IngressoRecordFasciaEta	
	SET @ret = ERROR_NUMBER()
	DECLARE @dove AS VARCHAR(50)
	SELECT @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH


RETURN 0


GO
