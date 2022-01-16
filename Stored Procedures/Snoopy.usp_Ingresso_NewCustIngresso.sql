SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE    PROCEDURE [Snoopy].[usp_Ingresso_NewCustIngresso] 
@UserID				int,
@CustID				int,
@newbirthdate		DATETIME,
@SiteID 			int,
@osserv				VARCHAR(50),
@CardID				INT,
@cardEntryMode		INT,
@fk_controlid		INT,
@fidelitypoints		INT OUTPUT	
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
	raiserror('Invalid CustomerID (%d) specified',16,1,@CustID)
	return (1)
END
IF @CardID is NOT NULL and not exists (
	select m.CustomerID 
	from GoldenClub.tbl_Members m
	inner join Snoopy.tbl_Customers c on c.CustomerID = m.CustomerID
	where m.CustomerID = @CustID 
	and m.CancelID is null 
	and c.CustCancelID is null
	and m.GoldenClubCardID = @CardID
	)
	
begin
	raiserror('Invalid CustomerID (%d) Customer is not Golden Member',16,1,@CustID)
	return (1)
END

--in entrata we have to specify the UserID
IF @UserID is null or not exists (select UserID from CasinoLayout.Users where UserID = @UserID)
begin
	raiserror('Invalid UserID (%d) specified',16,1,@UserID)
	return (1)
end

	--if not controllo from a sesam position stop here and do nothing
IF NOT EXISTS
(
	SELECT s.SiteID
	FROM CasinoLayout.Sites s
	WHERE s.SiteID = @SiteID AND s.SiteTypeID = 2 --only for sesam entrance
)
BEGIN
	RETURN 0
END

declare @docID int
declare @rifiuto int
declare @FName varchar(256)
declare @LName varchar(256)
declare @SecName varchar(256)
declare @attribs varchar(4096)
DECLARE @startUseOFMobile DATETIME
DECLARE @birthdate DATETIME


SELECT 
	@FName				= c.FirstName,
	@LName				= c.LastName,
	@birthdate			= c.BirthDate,
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
declare @TimeStampUTC	datetime
,@TimeStampLoc			datetime
,@gaming				datetime
,@ret					int

set @TimeStampUTC = getutcdate()
set @TimeStampLoc = getdate()
set @Gaming = [GeneralPurpose].[fn_GetGamingLocalDate2](@TimeStampLoc,0,22) --change at 10 am for Veto position

SET @fidelitypoints = 0
set @ret = 0

BEGIN TRANSACTION trn_IngressiNewIngresso

BEGIN TRY  

	DECLARE @visits INT,@visitQRCode INT

	SELECT @visits			= ISNULL(COUNT(entratatimestampUTC),0),
			@visitQRCode	= ISNULL(COUNT(CASE WHEN FK_CardEntryModeID = 3 THEN 1 ELSE NULL end),0)
	FROM Reception.tbl_CustomerIngressi 
	WHERE GamingDate  = @gaming AND CustomerID = @CustID


	INSERT INTO Reception.tbl_CustomerIngressi
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
	0,--isuscita
	@cardEntryMode,
	@fk_controlid
	)
	

	--check if we entered the birthdate
	IF @birthdate IS NULL OR @birthdate = '1.1.1900' AND @newbirthdate IS NOT NULL AND @newbirthdate > '1.1.1900'
	BEGIN
		UPDATE Snoopy.tbl_Customers SET BirthDate = @newbirthdate WHERE CustomerID = @CustID
	END

	COMMIT TRANSACTION trn_IngressiNewIngresso
	SET @visits += 1
	IF @cardEntryMode = 3 --read from mobile
		SET @visitQRCode += 1


--controlla se esiste una restituzione e notificala
/*

	declare @custid int
	set @custid = 56176

--*/
	DECLARE @maxRestID INT
	SELECT @maxRestID = MAX([PK_RestituzioneID])
	FROM [Snoopy].[vw_AllCustomerRestituizioni]
	WHERE CustomerID = @CustID AND [RestGamingDate] IS NULL

	IF @maxRestID IS NOT NULL
    BEGIN

/*

	INT						m_CustomerID		;
	INT						m_RettificaStockID	;
	INT						m_RettificaRestituzioneID;
	INT						m_DenaroTrovatoID		;
	CString					m_RettificaTag			;
	CString					m_LastName			;
	CString					m_FirstName			;
	COleDateTime			m_RestGamingDate	;
	COleDateTime			m_RestOraLoc		;
	COleDateTime			m_InsertGamingDate	;
	COleDateTime			m_InsertOraLoc		;



*/

		SELECT 
			r.PK_RestituzioneID,
			r.Causale,
			r.CustomerID		,
			r.RettificaStockID	,
			r.RettificaRestituzioneID,
			r.DenaroTrovatoID		,
			r.RettificaTag			,
			r.LastName			,
			r.FirstName			,
			InsertGamingDate,	
			InsertOra		
		FROM [Snoopy].[vw_AllCustomerRestituizioni] r		
		WHERE  r.[PK_RestituzioneID] = @maxRestID
/*
	declare @attribs varchar(1024) 
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) +
		''' RestituzioneID=''' + CAST(PK_RestituzioneID as varchar(32)) +
		''' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](r.InsertOra) +			
		''' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](r.InsertGamingDate) +			
		''' Causale=''' + r.Causale +
		''' RettificaRestituzioneID=''' + ISNULL( CAST(r.RettificaRestituzioneID as varchar(32)),'') +
		''' RettificaStockID=''' + ISNULL(CAST(r.RettificaStockID as varchar(32)),'') +
		''' RettificaTag=''' + ISNULL(r.RettificaTag,'') +
		''' Lastname=''' + r.LastName collate Latin1_General_CI_AS +
		''' Firstname=''' + r.FirstName collate Latin1_General_CI_AS +
		''' DenaroTrovatoID=''' + ISNULL( CAST(r.DenaroTrovatoID as varchar(32)),'') + ''''
		FROM [Snoopy].[vw_AllCustomerRestituizioni] r		
		WHERE  r.[PK_RestituzioneID] = @maxRestID
	PRINT @attribs
	*/
	SELECT [GeneralPurpose].[fn_BroadcastMessage]  (
		'Restituzione',
		' CustID=''' + CAST(@custid as varchar(32)) +
		''' RestituzioneID=''' + CAST(PK_RestituzioneID as varchar(32)) +
		''' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](r.InsertOra) +			
		''' GamingDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](r.InsertGamingDate) +			
		''' Causale=''' + r.Causale +
		''' SiteName=''' + @SiteName +
		''' RettificaRestituzioneID=''' + ISNULL( CAST(r.RettificaRestituzioneID as varchar(32)),'0') +
		''' RettificaStockID=''' + ISNULL(CAST(r.RettificaStockID as varchar(32)),'0') +
		''' RettificaTag=''' + ISNULL(r.RettificaTag,'') +
		''' LastName=''' + r.LastName collate Latin1_General_CI_AS +
		''' FirstName=''' + r.FirstName collate Latin1_General_CI_AS +
		''' DenaroTrovatoID=''' + ISNULL( CAST(r.DenaroTrovatoID as varchar(32)),'0') + ''''
		)
	FROM [Snoopy].[vw_AllCustomerRestituizioni] r
	WHERE r.[PK_RestituzioneID] = @maxRestID

	END
    

END TRY  
BEGIN CATCH  

	ROLLBACK TRANSACTION trn_IngressiNewIngresso
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove

END CATCH	


	/*ora notifica l'entrata*/

	if @CardID is null
		set @CardID = 0
        
	IF @CardID > 0 AND @cardEntryMode = 3 --read from mobile
	BEGIN

		--if first visit of the gamingdate with app
		IF @visitQRCode = 1 
		begin
			--mark we are using the mobile at the entrance for the first time
			IF @startUseOFMobile IS NULL
			BEGIN
				DECLARE @dummy datetime
				EXECUTE [GoldenClub].[usp_MobileAppVerified] @CardID,@dummy output

			END
			        
			--update entry points in dos app and get fidelitypoints from API
			DECLARE @errorMsg varchar(1024)
		
			EXEC	@ret = [GeneralPurpose].[usp_DOSGroup_AddPoint]
					@cardid,
					@fidelitypoints OUTPUT,
					@errorMsg OUTPUT	
		END
		ELSE
        BEGIN
			--just get fidelity points from mariadb for info display
			EXECUTE @ret = [GoldenClub].[usp_DOSGroup_GetFidelityPoints] @CardID,@fidelitypoints OUTPUT

        END
	END

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
		' EntryMode='''		+ CAST(@cardEntryMode as varchar(32)) + '''' + 
		' Fidelity='''		+ CAST(@fidelitypoints as varchar(32)) + '''' 
	-- print @attribs

	IF @osserv IS NOT NULL
		SET @attribs = @attribs + 
			' Osser=''' + @osserv + '''' 
	
	execute [GeneralPurpose].[usp_BroadcastMessage] 'EntrataCK',@attribs




return @ret
GO
