SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO




CREATE  PROCEDURE [Snoopy].[usp_Ingresso_RecordFasciaEta] 
@fk_controlid		INT,
@fasciaeta			INT,
@sesso				BIT,
@proveninenza		INT,
@promo				VARCHAR(1024) OUTPUT
AS

DECLARE  @ret			INT,
@attribs varchar(4096)

BEGIN TRANSACTION trn_IngressoRecordFasciaEta

BEGIN TRY  


	INSERT INTO Reception.tbl_FasceEtaRegistrations
			   ([FK_ControlID]
			   ,[FasciaEtaID]
			   ,Sesso
			   ,ProvenienzaID)
     VALUES
         (@fk_controlid,@fasciaeta,@sesso,@proveninenza)


	COMMIT TRANSACTION trn_IngressoRecordFasciaEta

	DECLARE @sitename VARCHAR(32),@SiteId INT
	DECLARE @TimeStampUTC DATETIME
	DECLARE @TimeStampLoc DATETIME
	DECLARE @gaming		  DATETIME

	SELECT @SiteID = s.SiteID,@sitename = s.FName
	FROM Reception.tbl_VetoControls c
	INNER JOIN CasinoLayout.Sites s ON s.SiteID = c.SiteId
	WHERE PK_ControllID = @fk_controlid AND s.SiteTypeID = 2 --only for sesam entrance

	IF @SiteId IS NOT NULL
	BEGIN

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

	--controlla se ci sono promozioni in corso per le postazioni sesam
		/*

		declare @fk_controlid	INT,
		@gaming		  DATETIME,
@fasciaeta			INT,
@sesso				BIT,
@proveninenza		INT

		set @fk_controlid = 4907822
		SET @Gaming = [GeneralPurpose].[fn_GetGamingLocalDate2](getutcdate(),1,22) --change at 10 am for Veto position

		select 
@fasciaeta = [FasciaEtaID],
@sesso				= [Sesso],
@proveninenza		= [ProvenienzaID] 
from [Snoopy].[tbl_FasceEtaRegistrations] WHERE FK_ControlID = @fk_controlid
		--*/

	DECLARE @Promozione VARCHAR(50)
	SELECT @Promozione = Promozione FROM [Marketing].[vw_PromozioniInCorso] WHERE ConsegnaSiteTypeID  = 2
	IF @Promozione IS NOT null
	BEGIN
		declare @controlString		VARCHAR(50)

		--controlla la string con cui è stata fatta la ricerca
		SELECT @controlString = searchString FROM Reception.tbl_VetoControls WHERE PK_ControllID = @fk_controlid

		SELECT @controlString

		declare 
		@ini			INT,
		@end			INT,
		@l				varchar(16),
		@f				VARCHAR(16),
		@b				VARCHAR(16)


		--estrai lastname
		SET @ini = CHARINDEX('l=''',@controlString,0)
		IF @ini > 0
		begin
			SET @end = CHARINDEX('''',@controlString,@ini+3)

			IF @ini > 0 AND @end > @ini
				SET @l = SUBSTRING(@controlString,@ini +3, @end - @ini - 3)
		END
		--SELECT @ini,@end,@l

		--estrai firstname
		SET @ini = CHARINDEX('f=''',@controlString,0)
		IF @ini > 0
		begin
			SET @end = CHARINDEX('''',@controlString,@ini+3)

			IF @ini > 0 AND @end > @ini
		SET @f = SUBSTRING(@controlString,@ini +3, @end - @ini - 3)
		END
		--SELECT @ini,@end,@f

	
		--estrai birthdate
		SET @ini = CHARINDEX('b=''',@controlString,0)
		IF @ini > 0
		begin
			SET @end = CHARINDEX('''',@controlString,@ini+3)

			IF @ini > 0 AND @end > @ini
		SET @b = SUBSTRING(@controlString,@ini +3, @end - @ini - 3)
		END
		--SELECT @ini,@end,@b


		IF @l IS NOT NULL OR @f IS NOT NULL OR @b IS NOT null 
		BEGIN
 			DECLARE @sql NVARCHAR(4000)
       
			SET @sql = 
				'select @Count = count(*)  from [Snoopy].[vw_AllVetoFasceEtaRegistrations]' + 
				--cerca prima solo nel gamingdate corrente
				' WHERE gamingdate = ''' + CONVERT(NVARCHAR(28),@gaming,23) + '''' +
				--non contare il cotnrollo corrente
				' AND [ControlID] <> ' + CAST( @fk_controlid AS NVARCHAR(16)) 

			IF @fasciaeta IS NOT NULL
				--stessa fascia eta 
				SET @sql += ' AND [FasciaEtaID] = ' + CAST( @fasciaeta AS NVARCHAR(16)) 
			

				--stessa sesso
			IF @sesso IS NOT NULL
				SET @sql += ' AND [Sesso] = ' + CAST( @sesso AS NVARCHAR(16)) 
				--stessa provenienza
			IF @proveninenza IS NOT NULL
				SET @sql += ' AND [ProvenienzaID] = ' + CAST( @proveninenza AS NVARCHAR(16)) 

			
			
			IF @l IS NOT NULL
				SET @sql += ' AND [searchString] LIKE ''%' + @l + '%'''
			IF @f IS NOT NULL
				SET @sql += ' AND [searchString] LIKE ''%' + @f + '%'''
			IF @b IS NOT NULL
				SET @sql += ' AND [searchString] LIKE ''%' + @b + '%'''


			SELECT @sql
	 
			DECLARE @outCount INT;
			DECLARE @params NVARCHAR(255) = '@Count INT OUTPUT'

			EXEC sp_executeSQL @SQL, @params, @Count = @outCount OUTPUT;			
			
			if @outCount IS NOT NULL AND @outCount > 0
			BEGIN
				SET @promo = 'E'' in corso la promozione ' + @Promozione + '.' + CHAR(13) + CHAR(10) 
				+ 'Il cliente è già entrato ' + CAST(@outCount AS VARCHAR(12)) 
				+ CASE WHEN @outCount = 1 THEN ' volta' else  ' volte' END
            END
		END

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
