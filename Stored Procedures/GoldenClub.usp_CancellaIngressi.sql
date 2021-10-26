SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [GoldenClub].[usp_CancellaIngressi] 
@UserID		int,
@CustID		int,
@SiteID 	int
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
end

if @UserID is null or not exists (select UserID from CasinoLayout.Users where UserID = @UserID)
begin
	raiserror('Invalid UserID (%d) specified',16,1,@UserID)
	return (1)
end

declare @FName varchar(256)
declare @LName varchar(256)
declare @UName varchar(256)
declare @attribs varchar(4096)

select @UName = LastName from CasinoLayout.Users where UserID = @UserID

select @FName=FirstName,
@LName=LastName
from Snoopy.tbl_Customers  c 
LEFT OUTER JOIN CasinoLayout.Sectors sec ON sec.SectorID = c.SectorID
where c.CustomerID = @CustID

declare @TimeStampLoc datetime
declare @gaming		  datetime

--get current GamingDate
set @TimeStampLoc = GETDATE()
set @Gaming = [GeneralPurpose].[fn_GetGamingDate](@TimeStampLoc,0,default) --change at 9 am by default


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CancellaIngressi

BEGIN TRY  




	delete from Snoopy.tbl_CustomerIngressi
	where CustomerID = @CustID and GamingDate=@Gaming
	AND IsUscita = 0

	select @attribs = 
		'CustID=''' + CAST(@custid as varchar(32)) + '''' + 
		' Ora=''' + cast(datePart(hh,@TimeStampLoc) as varchar(4)) + ':' + cast(datePart(mi,@TimeStampLoc) as varchar(4)) + '''' + 
	--	' TransTimeLoc=''' + [GeneralPurpose].[fn_CastDateForAdoRead](@TimeStampLoc) + '''' +
		' FirstName=''' 	+ @FName + '''' +
		' LastName=''' 		+ @LName + '''' +
		' UserName=''' 		+ @UName + '''' +
		' SiteName=''' 		+ @SiteName + ''''
	-- print @attribs

	execute [GeneralPurpose].[usp_BroadcastMessage] 'DeleteAllEntrateCK',@attribs


	COMMIT TRANSACTION trn_CancellaIngressi

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CancellaIngressi
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
