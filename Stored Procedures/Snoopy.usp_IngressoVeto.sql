SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



CREATE  PROCEDURE [Snoopy].[usp_IngressoVeto] 
@fk_controlid		INT,
@fasciaeta			INT
AS

DECLARE  @ret			INT,
@attribs varchar(4096)

BEGIN TRANSACTION trn_IngressoVeto

BEGIN TRY  


	INSERT INTO Snoopy.tbl_FasceEtaRegistrations
			   ([FK_ControlID]
			   ,[FasciaEtaID])
     VALUES
         (@fk_controlid		,@fasciaeta	)


	COMMIT TRANSACTION trn_IngressoVeto

	DECLARE @sitename VARCHAR(32),@SiteId int

	SELECT @SiteID = s.SiteID,@sitename = s.FName
	FROM Snoopy.tbl_VetoControls c
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteId
	WHERE PK_ControllID = @fk_controlid AND s.SiteTypeID = 2 --only for sesam entrance

	IF @SiteId IS NOT null
	begin
		declare @TimeStampUTC datetime
		declare @TimeStampLoc datetime
		declare @gaming		  datetime

		set @TimeStampUTC = getutcdate()
		set @TimeStampLoc = getdate()
		set @Gaming = [GeneralPurpose].[fn_GetGamingLocalDate2](@TimeStampLoc,0,22) --change at 10 am for Veto position
		select @attribs = 
			'SiteID=''' 		+ CAST(@SiteID as varchar(32)) + '''' +
			' SiteName=''' 		+ @SiteName + '''' +
			' GamingDate='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@Gaming) + '''' +
			' TransTimeLoc='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' +
			' CustID=''-3''' + 
			' Visite = ''1'''  

		execute [GeneralPurpose].[usp_BroadcastMessage] 'EntrataCK',@attribs
	end

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_IngressoVeto	
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH


RETURN 0


GO
