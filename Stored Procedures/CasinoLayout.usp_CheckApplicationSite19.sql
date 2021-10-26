SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO






/*
This procedure checks that the application can run on the specified computer and
returns all Stocks attached to the specified computer that can be handled by the specified 
application
*/
CREATE PROCEDURE [CasinoLayout].[usp_CheckApplicationSite19] 
@appID				INT,
@computerName		VARCHAR(50),
@StockTypeID		INT
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

declare 
@SiteID				INT ,
@SiteTypeID			INT ,
@siteName			VARCHAR(256) ,
@DRGTNetworkAddr	VARCHAR(50) ,
@DRGTPortNo			INT ,
@AdunoTerminal		BIT ,
@GlobalCash			BIT ,
@IsSesamEntrance	BIT ,
@IsCassa			BIT ,
@IPAddrSUR			VARCHAR(32) ,
@IPPortNumberSUR	int,
@appName			VARCHAR(256) ,
@adminID			INT 

--check now the site ID
--remember to return sysadmin group id
select @adminID = UserGroupID from CasinoLayout.UserGroups where FName = 'SysAdmins'
select @appName = FName from [GeneralPurpose].[Applications] where ApplicationID = @appID
--always return the sorveglianza PC ip addr and Occhio port
DECLARE @surSiteID INT
--prendi quello con ID piu basso
select @surSiteID = min(SiteID)	
from CasinoLayout.Sites where SiteTypeID = 6 --tipo sorveglianza
AND OcchioPort IS NOT NULL AND ComputerIP IS NOT NULL

IF @surSiteID IS NOT null
	select 
	@IPAddrSUR		= ComputerIP,
	@IPPortNumberSUR = OcchioPort	
	from CasinoLayout.Sites si
		where si.SiteID = @surSiteID

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
declare @Stocks int


IF (@StockTypeID <> -1 )
	--get all Stocks attached to the site of the specified stock type
		SELECT @Stocks = count(*)
		FROM [CasinoLayout].[vw_WhoDoesWhatWhere]
			WHERE 	SiteID = @SiteID AND 
			ApplicationID = @appID AND
			StockTypeID = @StockTypeID
ELSE
	--get all Stocks attached to the site of any stock type
		SELECT @Stocks = count(*)
		FROM [CasinoLayout].[vw_WhoDoesWhatWhere]
		WHERE
			SiteID = @SiteID AND 
			ApplicationID = @appID


if  @Stocks is not null and  @Stocks > 0
begin
	IF (@StockTypeID <> -1 )
		--get all Stocks attached to the site of the specified stock type
			SELECT 
			@SiteID				AS SiteID				,		
			@SiteTypeID			AS SiteTypeID			,
			@siteName			AS siteName			,
			@DRGTNetworkAddr	AS DRGTNetworkAddr	   ,
			@DRGTPortNo			AS DRGTPortNo			,
			@AdunoTerminal		AS AdunoTerminal		,
			@GlobalCash			AS GlobalCash			,
			@IsSesamEntrance	AS IsSesamEntrance	   ,
			@IsCassa			AS IsCassa			,
			@appName			as appName,
			@adminID			as adminID			,
			@IPAddrSUR			as IPAddrSUR		,
			@IPPortNumberSUR	as IPPortNumberSUR

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
			@SiteID				AS SiteID				,		
			@SiteTypeID			AS SiteTypeID			,
			@siteName			AS siteName			,
			@DRGTNetworkAddr	AS DRGTNetworkAddr	   ,
			@DRGTPortNo			AS DRGTPortNo			,
			@AdunoTerminal		AS AdunoTerminal		,
			@GlobalCash			AS GlobalCash			,
			@IsSesamEntrance	AS IsSesamEntrance	   ,
			@IsCassa			AS IsCassa			,
			@appName			as appName,
			@adminID			as adminID,
			@IPAddrSUR			as IPAddrSUR		,
			@IPPortNumberSUR	as IPPortNumberSUR
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
END
ELSE
BEGIN
	SELECT 
		@SiteID				AS SiteID				,		
		@SiteTypeID			AS SiteTypeID			,
		@siteName			AS siteName			,
		@DRGTNetworkAddr	AS DRGTNetworkAddr	   ,
		@DRGTPortNo			AS DRGTPortNo			,
		@AdunoTerminal		AS AdunoTerminal		,
		@GlobalCash			AS GlobalCash			,
		@IsSesamEntrance	AS IsSesamEntrance	   ,
		@IsCassa			AS IsCassa	,
			@appName			as appName,
			@adminID			as adminID,
			@IPAddrSUR			as IPAddrSUR		,
			@IPPortNumberSUR	as IPPortNumberSUR,
			@StockTypeID		as StockTypeID

END
GO
