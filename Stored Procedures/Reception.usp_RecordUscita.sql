SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [Reception].[usp_RecordUscita]
@siteID		int,
@increment	int,
@TotUscite	int output
AS

if @increment is null or (@increment <> 1 and @increment <> -1)
begin
		raiserror('invalid @increment specified',16,1)
		return (1)
	
end
if @siteID is null or not exists (select SiteID from CasinoLayout.Sites where SiteID = @SiteID)
begin
		raiserror('invalid @siteID specified',16,1)
		return (2)
end


-- get gaming date
declare @gaming datetime,@oraUTC datetime,@oraLoc datetime,@ultimaora DATETIME,@ret INT
declare @attribs varchar(max)

set @oraUTC = getutcdate()
SET @oraLoc = GETDATE()
select @gaming = GeneralPurpose.fn_GetGamingLocalDate2 (@oraUTC,1,22)

--ignora uscite se tra le 07 e le 11
IF DATEPART(hh,@oraLoc) IN(7,8,9,10) 
BEGIN
		SET @TotUscite = 100000
		SELECT @attribs = 
					'GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@gaming) + '''' +
					' TimeLoc='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@oraLoc) + '''' +
					' Increment=''' 	+ CAST(@increment as varchar(32)) + '''' + 
					' SiteID=''' 		+ CAST(@SiteID as varchar(32)) + '''' +
					' SiteName=''' 		+ FName + ''''   +
					' TotUscite=''' 	+ CAST(@TotUscite as varchar(32)) + '''' 
				-- print @attribs
		from CasinoLayout.Sites where SiteID = @SiteID

		execute [GeneralPurpose].[usp_BroadcastMessage] 'UscitaCK',@attribs
END
ELSE
BEGIN

	SELECT @TotUscite = isnull(sum(Increment),0),@ultimaora = max(TimestampUTC) FROM Reception.tbl_Uscite
	WHERE GamingDate = @gaming

	--trascura conteggi troppo vicini 
	if @ultimaora is null or datediff(second,@ultimaora,@oraUTC) > 1 --1 seconds
	begin

		BEGIN TRANSACTION trn_RecordUscita

		BEGIN TRY  

			INSERT INTO Reception.tbl_Uscite
					   ([SiteID]
					   ,[TimestampUTC]
					   ,[Increment]
					   ,[GamingDate]
					   )
			VALUES
					   (@SiteID
					   ,@oraUTC
					   ,@increment
					   ,@gaming)


			COMMIT TRANSACTION trn_RecordUscita
		END TRY  
		BEGIN CATCH  

			ROLLBACK TRANSACTION trn_RecordUscita
			set @ret = error_number()
			declare @dove as varchar(50)
			select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
			EXEC [Managers].[msp_HandleError] @dove

		END CATCH	

		set @TotUscite += 1

		SELECT @attribs = 
					'GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@gaming) + '''' +
					' TimeLoc='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@oraLoc) + '''' +
					' Increment=''' 	+ CAST(@increment as varchar(32)) + '''' + 
					' SiteID=''' 		+ CAST(@SiteID as varchar(32)) + '''' +
					' SiteName=''' 		+ FName + ''''   +
					' TotUscite=''' 	+ CAST(@TotUscite as varchar(32)) + '''' 
				-- print @attribs
		from CasinoLayout.Sites where SiteID = @SiteID

		execute [GeneralPurpose].[usp_BroadcastMessage] 'UscitaCK',@attribs

	END
END

RETURN @ret
GO
GRANT EXECUTE ON  [Reception].[usp_RecordUscita] TO [rasSesam3]
GO
