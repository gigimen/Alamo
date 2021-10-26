SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [GoldenClub].[usp_RemoveDiscalim]
@CustID 		int,
@UserAccessID		int,
@TimeStampLoc	 	datetime output,
@SiteName 		varchar(64) output
AS

--check input values
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid user access(%d) specified',16,1,@UserAccessID)
	return (1)
end
if @CustID is null or not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID and CancelID is not null)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer is not cancelled from GoldenClub',16,1,@CustID)
	return (2)
end

select @SiteName = CasinoLayout.Sites.FName 
FROM    FloorActivity.tbl_UserAccesses 
	INNER JOIN  CasinoLayout.Sites
	ON CasinoLayout.Sites.SiteID = FloorActivity.tbl_UserAccesses.SiteID 
where FloorActivity.tbl_UserAccesses.UserAccessID = @UserAccessID



set @TimeStampLoc = getutcdate()

declare @cancID INT
select @cancID = CancelID 
from GoldenClub.tbl_Members
where CustomerID = @CustID

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_RemoveDiscalim

BEGIN TRY  


	--remove cancel action
	update GoldenClub.tbl_Members
		set CancelID = null
	where CustomerID = @CustID
	--finally delete CancelAction
	--delete from dbo.CancelActions 
	--where CancelID = @cancID


	--return the @TimeStampLoc in local hour
	set @TimeStampLoc=GeneralPurpose.fn_UTCToLocal(1,@TimeStampLoc)

	declare @attribs varchar(4096)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) + '''' +
		' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' +
		' SiteName=''' + @SiteName + ''''
 
	execute [GeneralPurpose].[usp_BroadcastMessage] 'GCCancDisclaim',@attribs
	/*
	<MESS type='GCDisclaim' CustID='253'/>
	*/

	COMMIT TRANSACTION trn_RemoveDiscalim

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_RemoveDiscalim
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
