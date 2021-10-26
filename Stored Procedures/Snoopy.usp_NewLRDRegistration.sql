SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [Snoopy].[usp_NewLRDRegistration]
@CustID 		int, -- Customer must exists first
@CauseID		int,
@RegStockID 		int,
@RegGamingDate 	datetime,
@ImportoSFr 	int,
@UserAccessID 	int,
@ModificaOra	int,
@Nota			VARCHAR(255),
@RegID			INT 		OUTPUT,
@idDate			DATETIME	OUTPUT,
@identificID	INT			OUTPUT,
@birthDate		DATETIME	output,
@RegTimeLoc		DATETIME	output
AS
--first some check on parameters
if not exists (select IdCauseID from Snoopy.tbl_IDCauses where IDCauseid = @CauseID and DenoID is not null)
begin
	raiserror('Invalid CauseId (%d) specified ',16,1,@CauseID)
	return 1
end

if @RegGamingDate is null
begin
	raiserror('Invalid GamingDate specified ',16,1)
	return 2
end

--insert of a new transaction
if not exists (select LifeCycleID from Accounting.tbl_LifeCycles where StockID = @RegStockID and GamingDate = @RegGamingDate)
begin
	raiserror('Invalid StockID (%d) specified for that gaming date',16,1,@RegStockID)
	return 3
end
if not exists (select UserAccessID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	return 4
end
if not exists (select CustomerID from Snoopy.tbl_Customers where CustomerID = @custid ) 
begin
	raiserror('Invalid Custid(%d) specified ',16,1,@custid)
	return 5
end

--first look for the customer in the customers table
declare @cancelId int
declare @RegTimeUTC datetime 

select 	
	@birthDate		= c.BirthDate,
	@idDate			= i.GamingDate,
	@identificID	= i.IdentificationID,
	@cancelId		= c.CustCancelID
from Snoopy.tbl_Customers c
	left outer join Snoopy.tbl_Identifications i
	on i.CustomerID = c.CustomerID
where c.CustomerID = @CustID 

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDRegistration

BEGIN TRY  



	if @cancelId is not null --formely cancelled
	begin
		--cancel cancel action and possibly also the identification information
		update Snoopy.tbl_Customers
			set CustCancelID = null,
			IdentificationID = null
		where CustomerID = @CustID

		DELETE FROM Snoopy.tbl_Identifications WHERE IdentificationID = @identificID

		--the undeleted customer will not be identified
		set @idDate = null
		set @birthDate = null	
		set @CauseId = null
	end

	if @RegID is null
	begin
		set @RegTimeUTC = GetUTCDate()
		set @RegTimeLoc = GetDate()
		--create a new registration
		insert into Snoopy.tbl_Registrations
		(
			CustomerID,
			StockID,
			TimeStampUTC,
			GamingDate,
			CauseID,
			AmountSFr,
			UserAccessID,
			CancelID,
			TimeStampLoc,
			Nota
		)
		VALUES
		(
			@CustID,
			@RegStockID,
			@RegTimeUTC,
			@RegGamingDate,
			@CauseID,
			@ImportoSFr,
			@UserAccessID,
			NULL,
			@RegTimeLoc,
			@Nota
		)

		set @RegID = SCOPE_IDENTITY()
	end
	else
	begin
		if @ModificaOra is null or @ModificaOra = 0
			select 
				@RegTimeLoc = TimeStampLoc,
				@RegTimeUTC = TimeStampUTC 
			from Snoopy.tbl_Registrations  
				where RegID = @RegID
		else --update also timestamp
		begin
			if @RegTimeLoc is null --we did not specify an hour: set to the current time
			begin
				set @RegTimeUTC = GETUTCDATE() 
				set @RegTimeLoc = GETDATE() 
			end
			else
				--calculate UTC time 
				set @RegTimeUTC = GeneralPurpose.fn_UTCToLocal(0, @RegTimeLoc)
		END
		--if @nota is null keep the existing
		IF @Nota IS NULL
			select @Nota = Nota	from Snoopy.tbl_Registrations  where RegID = @RegID
		update Snoopy.tbl_Registrations
			set CustomerID	= @CustID,
			StockID			= @RegStockID,
			gamingDate		= @RegGamingDate,
			TimeStampUTC	= @RegTimeUTC, 
			TimeStampLoc	= @RegTimeLoc, 
			CauseID			= @CauseID,
			AmountSFr		= @ImportoSFr,
			UserAccessID	= @UserAccessID,
			CancelID		= NULL,
			Nota			= @Nota
		where RegID			= @RegID

		--if used for identification update identification data also
		if exists(select RegID from Snoopy.tbl_Identifications where RegID = @RegID)
		begin
			update Snoopy.tbl_Identifications
				set IDCauseID = @CauseID
			where RegID = @RegID
		end
	end

	COMMIT TRANSACTION trn_NewLRDRegistration

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDRegistration
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
