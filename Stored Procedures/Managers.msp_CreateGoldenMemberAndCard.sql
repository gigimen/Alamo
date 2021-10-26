SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_CreateGoldenMemberAndCard]
@CustID 			int,
@memberTypeID 		int,
@UserAccessID		int,
@GoldenClubCardID 	int output,
@TimeStampLoc	 	datetime output
AS

--check input values
if @CustID is null or exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID)
begin
	raiserror('Invalid CustomerID (%d) specified or Customer already part of GoldenClub',16,1,@CustID)
	return (2)
end

/*
--first create new card number
execute GoldenClub.usp_CreateGoldenCard 
	@CustID,
	@GoldenClubCardID output
	*/
set @TimeStampLoc = GetUTCDATE()


DECLARE @defGoldParam INT
select @defGoldParam = [DefaultGoldenParams] from GoldenClub.tbl_MemberTypes where MemberTypeID = @memberTypeID
IF @defGoldParam IS NULL
begin
	raiserror('Invalid MemberTypeID (%d) specified',16,1,@memberTypeID)
	return (2)
END

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
	''' CardID=''' + CAST(@GoldenClubCardID as varchar(32)) +
	''' TimeStampLoc=''' +  [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + 
	''' TempCard=''0'''
 
execute [GeneralPurpose].[usp_BroadcastMessage] 'NewGoldenMember',@attribs
<MESS type='AssociaCard' CustID='253' CardID='508' TimeStampLoc='39971.6' UserID='266' SMSNumber='+393200552824' EMailAddress='giuse@cas.it' IDDocID='11194' TempCard='0'/>
*/
GO
