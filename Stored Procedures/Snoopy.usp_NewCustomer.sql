SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE         PROCEDURE [Snoopy].[usp_NewCustomer]
@LastName 		varchar(256),
@FirstName 		varchar(256),
@BirthDate		datetime,
@Sesso			bit,
@SectorID		INT,
@UserAccessID 	int,
@CustID 		int output,
@insertDate		datetime output
AS

--check input values
declare @UserID int
select @UserID = UserID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID


if @UserID is null
begin
	raiserror('Invalid user access specified',16,1)
	return (2)
end
if @LastName is null or len(@LastName) = 0
begin
	raiserror('Invalid LastName specified',16,1)
	return (2)
end
if @FirstName is null or len(@FirstName) = 0
begin
	raiserror('Invalid FirstName specified',16,1)
	return (2)
end
if @BirthDate is null 
begin
	raiserror('Invalid BirthDate specified',16,1)
	return (2)
end
if @Sesso is null 
begin
	raiserror('Invalid NULL Sex specified',16,1)
	return (2)
END

if @SectorID IS not null AND NOT EXISTS (SELECT SectorID FROM CasinoLayout.Sectors WHERE SectorID = @SectorID)
begin
	raiserror('Invalid NULL @SectorID (%d) specified',16,1, @SectorID)
	return (2)
end

--check if exist already a customer with that name and BirthDate
if @CustID is null
	select 	@CustID = CustomerID,
			@insertDate = InsertDate
	from Snoopy.tbl_Customers c
	where c.LastName = @LastName 
		and c.FirstName = @FirstName 
		and c.BirthDate = @BirthDate
		and c.Sesso = @Sesso

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewCustomer

BEGIN TRY  



	--if customer already in the list
	if @CustID is not null
	begin
		--update customer data 
		update Snoopy.tbl_Customers
			set BirthDate			= @BirthDate,
				LastName			= @LastName,
				FirstName			= @FirstName,
				Sesso				= @Sesso,
				SectorID			= @SectorID,
				InsertUserAccessID	= @UserAccessID,
				--undelete him if previously deleted
				CustCancelID = null
		where CustomerID = @CustID

		select @InsertDate = InsertDate				
		from Snoopy.tbl_Customers c
		where CustomerID = @CustID
	
	end
	else --customer did not exists before
	begin
		--we have to enter a brand new customer
		--just insert the new customer
		set @insertDate = GetUTCDate()
		insert into Snoopy.tbl_Customers
		(
			LastName,
			FirstName,
			Sesso,
			InsertDate,
			BirthDate,
			SectorID,
			InsertUserAccessID
		)
		VALUES
		(
			RTRIM(@LastName),
			RTRIM(@FirstName),
			@Sesso,
			@insertDate,
			@BirthDate,
			@SectorID,
			@UserAccessID
		)
		set @CustID = SCOPE_IDENTITY()
	end



	if @insertDate is not null
	begin
		--return the idtime in local hour
		set @insertDate=GeneralPurpose.fn_UTCToLocal(1,@insertDate)
	end


	COMMIT TRANSACTION trn_NewCustomer

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewCustomer
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
