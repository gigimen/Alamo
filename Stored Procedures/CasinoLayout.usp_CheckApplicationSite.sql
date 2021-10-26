SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



/*
This procedure checks that the application can run on the specified computer and
returns all stocks attached to the specified computer that can be handled by the specified 
application
*/
CREATE procedure [CasinoLayout].[usp_CheckApplicationSite] 
@appID				INT,
@computerName		VARCHAR(50),
@StockTypeID		INT,
@SiteID				INT output,
@siteName			VARCHAR(256) output,
@CashlessTerminal	int OUTPUT,
@TicketTerminal		INT OUTPUT,
@AdunoTerminal		bit OUTPUT,
@GlobalCash			bit OUTPUT,
--@CornerBank			bit OUTPUT,
@IsSesamEntrance	bit OUTPUT,
@IsCassa			bit OUTPUT,
@appName			VARCHAR(256) output,
@adminID			INT output
AS
--declare @AdunoTerminal bit 
--declare @GlobalCashTerminal bit 

if (@appID is null) or
	(not exists(select ApplicationID from [GeneralPurpose].[Applications] where ApplicationID = @appID))
begin
	raiserror('Must specify an existing ApplicationID',16,-1)
	return (1)
end
if (@stockTypeID <> -1 ) and (
	(@stockTypeID is null) or
	(not exists(select StockTypeID from CasinoLayout.StockTypes where StockTypeID = @stockTypeID))
	)
begin
	raiserror('Must specify an existing StockTypeID',16,-1)
	return (1)
end
if (@computerName is null) 
begin
	raiserror('Must specify the Computer Name',16,-1)
	return (1)
end
--check now the site ID
--remember to return sysadmin group id
select @adminID = UserGroupID from CasinoLayout.UserGroups where FName = 'SysAdmins'
select @appName = FName from [GeneralPurpose].[Applications] where ApplicationID = @appID
select 
	@SiteID				= SiteID	,
	@siteName			= FName		,
	@CashlessTerminal	= CashlessTerminal	,
	@TicketTerminal		= TicketTerminal,
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
	return (1)
END

DECLARE @IsOnFloorEuro BIT
SET @IsOnFloorEuro = 0

IF @IsCassa = 1 
BEGIN
	IF EXISTS (SELECT FloorID FROM CasinoLayout.Floor_Sites WHERE SiteID = @SiteID AND FloorID = 3)
		SET @IsOnFloorEuro = 1
END 

if (@stockTypeID <> -1 )
	--get all stocks attached to the site of the specified stock type
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
			where 	SiteID = @siteID and 
			ApplicationID = @appID and
			StockTypeID = @stockTypeID
else
	--get all stocks attached to the site of any stock type
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
		where
			SiteID = @siteID and 
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
