SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO





/*
This procedure checks that the application can run on the specified computer and
returns all Stocks attached to the specified computer that can be handled by the specified 
application
*/
CREATE PROCEDURE [CasinoLayout].[usp_CheckApplicationSiteEx] 
@appID				INT,
@computerName		VARCHAR(50),
@StockTypeID		INT,
@SiteID				INT OUTPUT,
@SiteTypeID			INT OUTPUT,
@siteName			VARCHAR(256) OUTPUT,
@DRGTNetworkAddr	VARCHAR(50) OUTPUT,
@DRGTPortNo			INT OUTPUT,
@AdunoTerminal		BIT OUTPUT,
@GlobalCash			BIT OUTPUT,
@IsSesamEntrance	BIT OUTPUT,
@IsCassa			BIT OUTPUT,
@appName			VARCHAR(256) OUTPUT,
@adminID			INT OUTPUT
AS
--declare @AdunoTerminal bit 
--declare @GlobalCashTerminal bit 

if (@appID is null) or
	(not exists(select ApplicationID from [GeneralPurpose].[Applications] where ApplicationID = @appID))
begin
	raiserror('Must specify an existing ApplicationID',16,-1)
	RETURN (1)
END
if (@StockTypeID <> -1 ) and (
	(@StockTypeID is null) or
	(not exists(select StockTypeID from CasinoLayout.StockTypes where StockTypeID = @StockTypeID))
	)
begin
	raiserror('Must specify an existing StockTypeID',16,-1)
	RETURN (1)
END
if (@computerName is null) 
begin
	raiserror('Must specify the Computer Name',16,-1)
	RETURN (1)
END
--check now the site ID
--remember to return sysadmin group id
select @adminID = UserGroupID from CasinoLayout.UserGroups where FName = 'SysAdmins'
select @appName = FName from [GeneralPurpose].[Applications] where ApplicationID = @appID
select 
	@SiteID				= SiteID	,
	@SiteTypeID			= SiteTypeID,
	@siteName			= FName		,
	@DRGTNetworkAddr	= DRGTNetworkAddr	,
	@DRGTPortNo			= DRGTPortNo,
	@AdunoTerminal		= AdunoTerminal		,
	@GlobalCash			= GlobalCash			,
	--@CornerBank			= CornerBank			,
	@IsSesamEntrance	= CASE WHEN si.SiteTypeID = 2 THEN 1 ELSE 0	END,
	@IsCassa			= CASE WHEN si.SiteTypeID = 1 THEN 1 ELSE 0	END			
	from CasinoLayout.Sites si
	where ComputerName = @computerName
if (@SiteID is null) 
begin
	raiserror('Computer %s not registered',16,-1,@computerName)
	RETURN (1)
END

DECLARE @IsOnFloorEuro BIT
SET @IsOnFloorEuro = 0

IF @IsCassa = 1 
BEGIN
	IF EXISTS (SELECT FloorID FROM CasinoLayout.Floor_Sites WHERE SiteID = @SiteID AND FloorID = 3)
		SET @IsOnFloorEuro = 1
END 

IF (@StockTypeID <> -1 )
	--get all Stocks attached to the site of the specified stock type
		SELECT 
				@IsOnFloorEuro AS IsOnFloorEuro
				,[ApplicationID]
				,[ApplicationName]
				,[SiteID]
				,[SiteName]
				,[ComputerName]
				,[StockID]
				,[Tag]
				,[StockTypeID]
		FROM [CasinoLayout].[vw_WhoDoesWhatWhere]
			WHERE 	SiteID = @SiteID AND 
			ApplicationID = @appID AND
			StockTypeID = @StockTypeID
ELSE
	--get all Stocks attached to the site of any stock type
		SELECT 
				@IsOnFloorEuro AS IsOnFloorEuro
				,[ApplicationID]
				,[ApplicationName]
				,[SiteID]
				,[SiteName]
				,[ComputerName]
				,[StockID]
				,[Tag]
				,[StockTypeID]
		FROM [CasinoLayout].[vw_WhoDoesWhatWhere]
		WHERE
			SiteID = @SiteID AND 
			ApplicationID = @appID


/*	COMMENTED OUT BECAUSE OF CASSA and MAIN CASSA application conflict where 
only simple trolleys are used. TO BE SOLVED SOMEHOW LATER.
else
begin
	raiserror('L''applicazione %s non puo'' essere lanciata da %s',16,-1,@appName,@siteName)
	return (1)
end
*/
GO
