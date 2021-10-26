SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [GoldenClub].[usp_IngressiNewIngresso] 
@UserID		int,
@CustID		int,
@SiteID 	int,
@osserv		VARCHAR(50),
@CardID		INT,
@IsUscita	BIT,
@cardEntryMode INT,
@fk_controlid		INT
AS

declare @SiteName varchar(32)

select @SiteName = FName
FROM CasinoLayout.Sites
where SiteID = @SiteID
if @SiteID is null
begin
	raiserror('Invalid SiteID (%d) specified',16,1,@SiteID)
	return (1)
end

--check input values
if @CustID is null or not exists (select CustomerID from Snoopy.tbl_Customers where CustomerID = @CustID and CustCancelID is null)
--if @CustID is null or not exists (select CustomerID from GoldenClub.Members where CustomerID = @CustID)
/*if @CustID is null or not exists (
	select m.CustomerID 
	from GoldenClub.Members m
	inner join dbo.Customers c on c.CustomerID = m.CustomerID
	where m.CustomerID = @CustID 
	and m.CancelID is null 
	and c.CustCancelID is null
	and m.GoldenClubCardID is not null
	)
	*/
begin
	raiserror('Invalid CustomerID (%d) specified or Customer is not Golden Member',16,1,@CustID)
	return (1)
END

--in entrata we have to specify the UserID
IF @IsUscita = 0 and @UserID is null or not exists (select UserID from CasinoLayout.Users where UserID = @UserID)
begin
	raiserror('Invalid UserID (%d) specified',16,1,@UserID)
	return (1)
end

DECLARE @err int
declare @docID int
declare @rifiuto int
declare @FName varchar(256)
declare @LName varchar(256)
declare @SecName varchar(256)
declare @attribs varchar(4096)
DECLARE @startUseOFMobile DATETIME


SELECT 
	@FName				= FirstName,
	@LName				= LastName,
	@SecName			= sec.SectorName,
	@docID				= g.IDDocumentID,
	@rifiuto			= g.CancelID,
	@startUseOFMobile	= g.StartUseMobileTimeStampUTC
from Snoopy.tbl_Customers  c 
LEFT OUTER JOIN GoldenClub.tbl_Members g ON g.CustomerID = c.CustomerID
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
where c.CustomerID = @CustID

if @SecName is null
	set @SecName = ''

if @docID is null
	set @docID = 0
if @rifiuto is not null
	set @rifiuto = 1 --il cliente ha rifiutato
else
	set @rifiuto = 0 --il cliente fa parte del golden club

declare @TimeStampUTC datetime
declare @TimeStampLoc datetime
declare @gaming		  datetime

set @TimeStampUTC = getutcdate()
set @TimeStampLoc = getdate()
set @Gaming = [GeneralPurpose].[fn_GetGamingLocalDate2](@TimeStampLoc,0,22) --change at 10 am for Veto position

/* individua gli scrocchi 

IF @Gaming >= '6.16.2025' --this is the starting day
--AND @IsUscita = 1 
BEGIN

	DECLARE @firstEntry DATETIME,@mins INT
	SELECT @firstEntry = MIN([entratatimestampUTC]) FROM GoldenClub.Ingressi WHERE CustomerID = @custid AND GamingDate = @Gaming
	set @mins = DATEDIFF(MINUTE,@firstEntry,@TimeStampUTC)
	
	IF @firstEntry IS NULL OR @mins >= (
	SELECT CAST(VarValue AS INT) FROM GeneralPurpose.ConfigParams WHERE VarName = 'ScrockVisitMintimeMinutes' AND VarType = 3
	) --more than 180 minutes visit
	BEGIN
		--if scrock cancel it
		IF GoldenClub.fn_IsGoldenParamSet (@custid,4096) = 1
		begin
			INSERT INTO GoldenClub.tbl_ScrockBand ([CustomerID],FirstEntryUTC,[Scrock])	 VALUES (@custid,@firstEntry,0)
			EXECUTE GoldenClub.usp_UnsetGoldenParam @custid, 4096
		end
    
	END
    
END

*/

/*
--in entrata controlla eventuali promozioni
ELSE
BEGIN

	--here is Avvento 2014
	DECLARE @startDate DATETIME,@endDate datetime
	select @startDate = ValidaDal,@endDate=ValidaAl FROM GoldenClub.Promotions WHERE PromotionID = 17 --Avvento 2014
	IF  @startDate is not null AND 
		@endDate is not null and
		@Gaming >= @startDate AND @Gaming <= @endDate
	begin

	declare 
		@premioID	int ,
		@giorniVignetta BIT ,
		@visiteNR   int,
		@premioDescr VARCHAR(50) ,
		@oraRitiro datetime 

		SET @premioID = null
		set @premioDescr = NULL
		SET @giorniVignetta = 0
		set @premioDescr = null
		set @visiteNR = NULL

		execute [Avvento2014].usp_GetPremioAvvento 
			@Gaming,
			@custID,
			@premioID output,
			@giorniVignetta OUTPUT,
			@visiteNR output,
			@premioDescr OUTPUT,
			@oraRitiro output

		SELECT @premioID		AS 'PremioID' ,
			   @premioDescr		AS 'PremioDescr' ,		
			   @giorniVignetta	AS 'GiornoVignetta' ,	
			   @visiteNR		AS 'VisiteNR' ,
			   @oraRitiro		AS 'OraConsegna'
		   	
	END	
end
*/
--raiserror('SiteID %d %s',16,1,@SiteID,@SiteName)
--return (1)

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_IngressiNewIngresso

BEGIN TRY  

	DECLARE @visits INT

	SELECT @visits = ISNULL(COUNT(entratatimestampUTC),0)
	FROM Snoopy.tbl_CustomerIngressi 
	WHERE GamingDate  = @gaming AND CustomerID = @CustID


	INSERT INTO Snoopy.tbl_CustomerIngressi
			   ([entratatimestampUTC]
			   ,[CustomerID]
			   ,[SiteID]
			   ,[CardID]
			   ,[Osservazione]
			   ,[entratatimestampLoc]
			   ,[GamingDate]
			   ,[UserID]
			   ,[IsUscita]
			   ,[FK_CardEntryModeID]
			   ,[FK_ControlID])
	VALUES  
	( 
	@TimeStampUTC,
	@CustID,
	@SiteID,
	@CardID,
	@osserv,
	@TimeStampLoc ,
	@gaming		  ,
	@UserID,
	@IsUscita,
	@cardEntryMode,
	@fk_controlid
	)
	
	SET @visits += 1

	if @CardID is null
		set @CardID = 0


	--if controllo from a sesam position
	IF @IsUscita = 0 AND EXISTS
    (
		SELECT s.SiteID
		FROM CasinoLayout.Sites s
		WHERE s.SiteID = @SiteID AND s.SiteTypeID = 2 --only for sesam entrance
	)
	BEGIN

		SELECT @attribs = 
			'CustID=''' + CAST(@custid as varchar(32)) + '''' + 
			' Ora=''' + cast(datePart(hh,@TimeStampLoc) as varchar(4)) + ':' + cast(datePart(mi,@TimeStampLoc) as varchar(4)) + '''' + 
			' GamingDate='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@Gaming) + '''' +
			' TransTimeLoc='''	+  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' +
			' FirstName=''' 	+ @FName + '''' +
			' LastName=''' 		+ @LName + '''' +
			' SectorName=''' 	+ @SecName + '''' +
			' IDDocID=''' 		+ CAST(@docID as varchar(32)) + '''' + 
			' GCCardID=''' 		+ CAST(@cardID as varchar(32)) + '''' + 
			' SiteID=''' 		+ CAST(@SiteID as varchar(32)) + '''' +
			' SiteName=''' 		+ @SiteName + '''' +
			' Visite = '''		+ CAST(@visits as varchar(32)) + '''' + 
			' Rifiuto=''' 		+ CAST(@rifiuto as varchar(32)) + ''''  + 
			' EntryMode='''		+ CAST(@cardEntryMode as varchar(32)) + '''' 
		-- print @attribs

		IF @osserv IS NOT NULL
			SET @attribs = @attribs + 
				' Osser=''' + @osserv + '''' 
	
		execute [GeneralPurpose].[usp_BroadcastMessage] 'EntrataCK',@attribs

		--first visit with app
		IF @visits = 1 
		BEGIN
			if @cardEntryMode = 3 AND @CardID > 0 --read from mobile
			begin
				--mark we are using the mobile at the entrance
				IF @startUseOFMobile IS NULL
				BEGIN

					UPDATE GoldenClub.tbl_Members
						SET StartUseMobileTimeStampUTC = @TimeStampUTC
					WHERE CustomerID = @CustID
            
				END
			end    
			        
			--update entry points in dos app
			DECLARE	@points int,
					@errorCode int,
					@errorMsg varchar(1024)
/*
			EXEC	@ret = [GeneralPurpose].[usp_DOSGroup_AddPoint]
					@cardid,
					@points OUTPUT,
					@errorCode OUTPUT,
					@errorMsg OUTPUT
*/		
		end

	end

	COMMIT TRANSACTION trn_IngressiNewIngresso

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_IngressiNewIngresso
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
