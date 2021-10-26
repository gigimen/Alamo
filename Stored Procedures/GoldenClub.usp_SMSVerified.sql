SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
	
	
CREATE     PROCEDURE [GoldenClub].[usp_SMSVerified]
@CustID 		int,
@checkedsms		int,
@UserAccessID	int
AS

--check input values
--check input values
declare @logName varchar(64)
declare @siteID	 	int

select @logName = loginName,
 @siteID = SIteID
from FloorActivity.vw_AllUserAccesses where UserAccessID = @UserAccessID

if @logName is null
begin
	raiserror('Invalid user access(%d) specified',16,1,@UserAccessID)
	return (1)
end

if @siteID is null or not exists( select SiteID FROM CasinoLayout.Sites where SiteID = @siteID)
begin
	raiserror('Invalid user siteid(%d) specified',16,1,@siteID)
	return (1)
end
if @CustID is null or not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID and CancelID is null)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer is not part of GoldenClub',16,1,@CustID)
	return (2)
end

if exists (select CustomerID from  GoldenClub.tbl_Members where customerid = @CustID 
and (SMSNumber is null or GoldenParams & 1 = 1 ) 
)
begin
	raiserror('Cannot verify SMS number disabled or not existing',16,1)
	return (3)
end

declare @TimeStampUTC DATETIME
set @TimeStampUTC = getutcdate()
declare @site varchar(50)

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_SMSVerified

BEGIN TRY  



	select @site = FName FROM CasinoLayout.Sites where SiteID = @siteID
	if @checkedsms = 1
	begin
		update GoldenClub.tbl_Members
		set GoldenParams = GoldenParams | 2, --set smsnumbercheckd flag
			SMSNumberCheckedFromIPAddress = @site,
			SMSNumberCheckedTimestampUTC = @TimeStampUTC
		where SMSNumber in (select SMSNumber from GoldenClub.tbl_Members where customerid = @CustID)
	END
	ELSE
	BEGIN  
		update GoldenClub.tbl_Members
			set GoldenParams = GoldenParams & (~2), --unset smsnumbercheckd flag
			SMSNumberCheckedFromIPAddress = @site,
			SMSNumberCheckedTimestampUTC = @TimeStampUTC
		where SMSNumber in (select SMSNumber from GoldenClub.tbl_Members where customerid = @CustID)
	END


	--return more infos in message
	declare @PersonalClubCardID int
	select @PersonalClubCardID = GoldenClubCardID
	from GoldenClub.tbl_Cards
	where customerid = @CustID

	declare @IdDocID int
	declare @expdate datetime
	declare @DocInfo varchar(64)
	select 
		@expdate = d.ExpirationDate,
		@IdDocID = g.IDDocumentID,
		@DocInfo = dt.FDescription + ' ' + d.DocNumber
	from Snoopy.tbl_IDDocuments d
	inner join Snoopy.tbl_IDDocTypes dt on dt.IDDocTypeID = d.IDDocTypeID 
	inner join GoldenClub.tbl_Members g  on g.IDDocumentID = d.IDDocumentID	
	where g.CustomerID = @CustID

	--return the @TimeStampLoc in local hour
	set @TimeStampUTC=GeneralPurpose.fn_UTCToLocal(1,@TimeStampUTC)

	declare @attribs varchar(1024)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) +
		''' GCCardID=''' + CAST(GoldenClubCardID as varchar(32)) +
		''' TimeStampLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampUTC) +			
		''' User=''' + @logName +
		''' SMS=''' + SMSNumber +
		''' GCParams=''' + CAST(GoldenParams as varchar(32)) +
		''' EMail=''' + EMailAddress +
		''' DocInfo=''' + @DocInfo +
		''' ExpirDate=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@expdate) +			
		''' GCDocID=''' +   CAST(@IdDocID as varchar(32)) + ''''
	 from GoldenClub.tbl_Members 
	 where CustomerID = @custid
	execute [GeneralPurpose].[usp_BroadcastMessage] 'AssociaCard',@attribs
	/*
	<ALAMO version='1'><MESS type='AssociaCard' CustID='766' GCCardID='700' TimeStampLoc='40093.4' User='GoldenClub' SMS='+393000000000' EMail='' GCDocID='13625'/></ALAMO>
	*/

	COMMIT TRANSACTION trn_SMSVerified

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_SMSVerified
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
