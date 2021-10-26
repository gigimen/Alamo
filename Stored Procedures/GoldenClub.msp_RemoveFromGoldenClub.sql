SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [GoldenClub].[msp_RemoveFromGoldenClub]
@CustID 		int,
@UserAccessID	int,
@TimeStampLoc	datetime output,
@SiteName 		varchar(64) output
AS

declare @logName varchar(64)
select 
	@logName = loginName,
	@SiteName = SiteName
from FloorActivity.vw_AllUserAccesses 
where UserAccessID = @UserAccessID

if @logName is null
begin
	raiserror('Invalid user access(%d) specified',16,1,@UserAccessID)
	return (1)
end

if @CustID is null or not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer is not part of GoldenClub',16,1,@CustID)
	return (2)
end



set @TimeStampLoc = getutcdate()


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_Disclaim

BEGIN TRY  



	--first create a new CancelAction
	insert into FloorActivity.tbl_Cancellations 
		(CancelDate,UserAccessID)
		VALUES(@TimeStampLoc,@UserAccessID)
	declare @cancID int
	set @cancID = SCOPE_IDENTITY()

	DECLARE 
		@GoldenClubCardID INT,
		@PersonalCardID int

	SELECT @GoldenClubCardID = GoldenClubCardID
	FROM GoldenClub.tbl_Members
	WHERE CustomerID = @CustID

	SELECT @PersonalCardID = GoldenClubCardID
	FROM GoldenClub.tbl_Cards
	WHERE CustomerID = @CustID

	update GoldenClub.tbl_Members
		set 
		CancelID= @cancID,
		GoldenClubCardID = null--, --remove linked card that is no more needed
		--CHANGED 9.7.2014 Yuliya want to keep the numbers
		--SMSNumber = null --remove SMSNumber that is no more needed
	where CustomerID = @CustID

	IF @GoldenClubCardID IS NOT NULL and @PersonalCardID is not null
	begin
		--if the linked card is his personal card
		if @GoldenClubCardID = @PersonalCardID
		begin
			--also if he had a @PersonalCardID linked put it back to pronta per Consegna status
			UPDATE GoldenClub.tbl_Cards
			SET CardStatusID = 2
			WHERE GoldenClubCardID = @PersonalCardID and CardStatusID = 3 --in consegnata status
		END
		else  --the personal card was in daprodurre status then cancel id
		begin
			UPDATE GoldenClub.tbl_Cards
			SET CancelID= @cancID
			WHERE GoldenClubCardID = @PersonalCardID and CardStatusID = 4 --da produrre status
		end
	end
	--return the @TimeStampLoc in local hour
	set @TimeStampLoc=GeneralPurpose.fn_UTCToLocal(1,@TimeStampLoc)

	declare @attribs varchar(4096)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) + '''' +
		' TransTimeLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' +
		' SiteName=''' + @SiteName + ''''
 
	execute [GeneralPurpose].[usp_BroadcastMessage] 'GCDisclaim',@attribs
	/*
	<MESS type='GCDisclaim' CustID='253' SiteName='xxxx'/>
	*/

	COMMIT TRANSACTION trn_Disclaim

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_Disclaim
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
