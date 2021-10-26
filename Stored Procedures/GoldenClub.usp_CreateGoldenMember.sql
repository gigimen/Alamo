SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE      PROCEDURE [GoldenClub].[usp_CreateGoldenMember]
@CustID 			int,
@memberTypeID 		int,
@UserAccessID		int,
@TimeStampLoc		datetime output
AS

--check input values
if @CustID is null or exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer already part of GoldenClub',16,1,@CustID)
	return (2)
END

DECLARE @defGoldParam INT
select @defGoldParam = [DefaultGoldenParams] from GoldenClub.tbl_MemberTypes where MemberTypeID = @memberTypeID
IF @defGoldParam IS NULL
begin
	raiserror('Invalid MemberTypeID (%d) specified',16,1,@memberTypeID)
	return (2)
END
set @TimeStampLoc = getutcdate()

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateGoldenMember

BEGIN TRY  



	--now insert also into GoldenClub
	insert into GoldenClub.tbl_Members
		(
			CustomerID,
			InsertTimeStampUTC,
			InsertUserAccessID,
			GoldenParams,
			MemberTypeID
		)
	values(
		@CustID,
		@TimeStampLoc,
		@UserAccessID,
		@defGoldParam,
		@memberTypeID
	)
	
	--return the @TimeStampLoc in local hour
	set @TimeStampLoc=GeneralPurpose.fn_UTCToLocal(1,@TimeStampLoc)
	/*
	declare @attribs varchar(4096)
	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) +
		''' TimeStampLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + 
		''''
 
	execute [GeneralPurpose].[usp_BroadcastMessage] 'NewGoldenMember',@attribs
	*/


	COMMIT TRANSACTION trn_CreateGoldenMember

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateGoldenMember
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
