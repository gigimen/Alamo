SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Stored Procedure

CREATE PROCEDURE [Snoopy].[usp_NewLRDIdentifyCustomer]
@recordDocOnly  int,
@LastName 		varchar(256),
@FirstName 		varchar(256),
@Sesso			bit,
@Address 		varchar(256),
@DomicilioID 	int,
@Telefono 		varchar(32),
@BirthDate 		datetime,
@UserAccessID 	int,
@IDCauseID 		INT output,
@citizenshipID 	int,
@docNumber 		VARCHAR(256),
@docTypeID 		INT,
@expirationDate datetime,
@CustID 		INT output,
@IdDocID 		INT output,
@IdGaming 		DATETIME output,
@IdentificationID int output,
@IdTime 		DATETIME output,
@StockID 		INT,
@importo		int,
@note			varchar(255),
@RegID 			int output
AS


if @recordDocOnly is null
	set @recordDocOnly = 0
--check input values
declare @UserID int
select @UserID = UserID from FloorActivity.tbl_UserAccesses where UserAccessID = @UserAccessID


if @UserID is null
begin
	raiserror('Invalid user access specified',16,1)
	return (2)
end
if @docTypeID is null or not exists (select IDDocTypeID from Snoopy.tbl_IDDocTypes where IDDocTypeID = @docTypeID)
begin
	raiserror('Invalid IDDocTypeID specified',16,1)
	return (2)
end
if @DomicilioID is null or not exists (select NazioneID from Snoopy.tbl_Nazioni where NazioneID = @DomicilioID)
begin
	raiserror('Invalid DomicilioID specified',16,1,@DomicilioID)
	return (2)
end
if @citizenshipID is null or not exists (select NazioneID from Snoopy.tbl_Nazioni where NazioneID = @citizenshipID)
begin
	raiserror('Invalid CitizenshipID specified',16,1,@citizenshipID)
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
if @Address is null or len(@Address) = 0
begin
	raiserror('Invalid Address specified',16,1)
	return (2)
end
if @docNumber is null or len(@docNumber) = 0
begin
	raiserror('Invalid docNumber specified',16,1)
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
end


declare @Tag as varchar(32)
DECLARE @idecancelled INT

select @Tag = CasinoLayout.Stocks.Tag
from CasinoLayout.Stocks 
where CasinoLayout.Stocks.StockID = @StockID

--if we did not specify an existing customer

--check if exist already a customer with that name and BirthDate
if @CustID is NULL
BEGIN

	--MARK THE IDENTIFICATION TIME IS NOW
	set @IdTime = GetUTCDate()

	--if we have to identify the customer it is going to be today
	if @recordDocOnly = 0 
		set @IdGaming =
			[GeneralPurpose].[fn_GetGamingLocalDate2](
				@IdTime,
				Datediff(hh,@IdTime,GeneralPurpose.fn_UTCToLocal(1,@IdTime)),
				4 --stock type tavoli
				)


	select 	
		@CustID				= c.CustomerID,
		@IdentificationID	= i.IdentificationID,
--		@IdTime				= i.InsertTimeStampUTC ,
--		@IdGaming			= i.GamingDate,
		@idecancelled		= i.[CancelID]
	from Snoopy.tbl_Customers c
		left outer join Snoopy.tbl_Identifications i on i.CustomerID = c.CustomerID
	where c.LastName		= @LastName 
		and c.FirstName		= @FirstName 
		and c.BirthDate		= @BirthDate

	IF @idecancelled IS NOT NULL --if a customer has been found whose identification was cancelled
		--we may modify the document of his identification
		-- and the regsitration of the original identification too
		SELECT 
		@IdDocID			= i.[IDDocumentID],
		@RegID				= i.RegID 
		FROM Snoopy.tbl_Identifications i
		WHERE IdentificationID = @IdentificationID
end
else
begin
	--are we going to change the name of an existing identification?
	--PRESERVE IDENTIFICATION TIME AND GamingDate
	select 	
		@IdentificationID	= i.IdentificationID,
		@IdTime				= i.InsertTimeStampUTC,
		@IdGaming			= i.GamingDate,
		@idecancelled		= i.[CancelID]
	from Snoopy.tbl_Customers c
	left outer join Snoopy.tbl_Identifications i on i.CustomerID = c.CustomerID
	where c.CustomerID = @CustID
/*
	--an identification EXISTS already and is not cancelled
	IF @recordDocOnly = 0 AND @IdentificationID IS NOT NULL
	BEGIN
		IF @idecancelled IS NULL
		begin
			raiserror('Customer %d already identified',16,1,@CustID)
			return (2)
		END
		ELSE
        BEGIN
			--rest time
			SET @IdTime = NULL
            SET @IdGaming = NULL
        END
        
	END
*/	    
	if @IDCauseID is null
		select 	@IDCauseID = i.IDCauseID
		from Snoopy.tbl_Customers c
		left outer join Snoopy.tbl_Identifications i on i.IdentificationID = c.IdentificationID
		where c.CustomerID = @CustID

end



if @recordDocOnly = 0
begin
	--this is a full identification

	if @IDCauseID is null or not exists (select IDCauseID from Snoopy.tbl_IDCauses where IDCauseID = @IDCauseID)
	begin
		raiserror('Invalid IDCauseID specified',16,1)
		return (2)
	end
	--we have to set the GamingDate to now 
	IF @IdGaming IS  NULL
    begin
		set @IdTime = GetUTCDate()
		set @IdGaming =
			[GeneralPurpose].[fn_GetGamingLocalDate2](
				@IdTime,
				Datediff(hh,@IdTime,GeneralPurpose.fn_UTCToLocal(1,@IdTime)),
				7 --stock type CC
				)
	end				
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDIdentifyCustomer

BEGIN TRY  





	declare @dummy1 datetime 
	declare @dummy2 datetime 

	declare @dummy4 int

	declare @RegTime datetime 

	declare @spec varchar(128)
	if @IDCauseID = 13 --altro
		SET @spec = @note
	ELSE
		SET @spec = NULL



	--if customer already in the list
	if @CustID is not null
	begin
		--first uncancel it
		update Snoopy.tbl_Customers set CustCancelID = null where CustomerID = @CustID AND CustCancelID IS NOT null

		--upadate or insert document information
		EXECUTE [Snoopy].[usp_NewLRDIDDocument] 
		   @CustID
		  ,@Address
		  ,@DomicilioID
		  ,@Telefono
		  ,@UserAccessID
		  ,@citizenshipID
		  ,@docNumber
		  ,@docTypeID
		  ,@expirationDate
		  ,@IdDocID OUTPUT


		if @recordDocOnly = 0 --this is a full identification
		BEGIN

			--first start with the registration
			if @importo is not null AND	EXISTS (select IDCauseID from Snoopy.tbl_IDCauses where IDCauseID = @IDCauseID and DenoID is not null)
			-- we need to register the transaction
			BEGIN

				--insert or update the existing registration
				execute [Snoopy].[usp_NewLRDRegistration]
					@CustID,
					@IDCauseID,
					@StockID,
					@IdGaming,
					@Importo,
					@UserAccessID,
					0,--do not modify hour
					@note, 
					@RegID output,
					@dummy1 output, --@idDate
					@dummy4 output,--identificID
					@dummy2 output, --@BirthDate
					@RegTime output

			END


			--then go with the identification
			if @IdentificationID is null
			begin

				--identification data must be created

				--insert a new identification
	--			print 'Insert new identification ' + @LastName

				INSERT into Snoopy.tbl_Identifications
					(
					CustomerID,
					InsertTimeStampUTC,
					GamingDate,
					IdentificationUserAccessID,
					IDDocumentID,
					IDCauseID,
					RegID,
					Note
					)
					Values
					(
					@CustID,
					@IdTime, 
					@IdGaming,
					@UserAccessID,
					@IdDocID,
					@IDCauseID,
					@RegID,
					@spec
					)

				set @IdentificationID = SCOPE_IDENTITY()			
			end
			else
			begin			
				--update cause id and Customer transaction link
				update Snoopy.tbl_Identifications
				set IDCauseID		= @IDCauseID,
					RegID			= @RegID,
					Note			= @spec,
					--uncancel it if cancelled before
					CancelID		= null,
					--update also timestamps
					[InsertTimeStampUTC] = @IdTime,
					GamingDate			 = @IdGaming,
					--and force a recheck from SM
					[SMCheckTimeStampUTC] = NULL,
					[SMCheckUserAccessID] = NULL
				where IdentificationID = @IdentificationID

			end

			--finally update customer information
			update Snoopy.tbl_Customers
			set BirthDate			= @BirthDate,
				IdentificationID	= @IdentificationID,
				LastName			= @LastName,
				FirstName			= @FirstName,
				Sesso				= @Sesso,
				NrTelefono			= @Telefono,
				--undelete him if previously deleted
				CustCancelID		= null
			where CustomerID = @CustID

		end
		else --just update customer information
		begin
			--update customer data 
			update Snoopy.tbl_Customers
				set BirthDate	= @BirthDate,
					LastName	= @LastName,
					FirstName	= @FirstName,
					Sesso		= @Sesso,
					NrTelefono	= @Telefono,
					--undelete him if previously deleted
					CustCancelID	= NULL
			where CustomerID = @CustID

		end
	end
	else --customer did not exists before
	begin
		--we have to enter a brand new customer
		--just insert the new customer

		insert into Snoopy.tbl_Customers
		(
			LastName,
			FirstName,
			Sesso,
			InsertDate,
			BirthDate,
			NrTelefono,
			InsertUserAccessID,
			IdentificationID
		)
		VALUES
		(
			RTRIM(@LastName),
			RTRIM(@FirstName),
			@Sesso,
			@IdTime,
			@BirthDate,
			@Telefono,
			@UserAccessID,
			null --null for now
		)

		set @CustID = SCOPE_IDENTITY()


		--upadate or insert document information
		EXECUTE [Snoopy].[usp_NewLRDIDDocument] 
		   @CustID
		  ,@Address
		  ,@DomicilioID
		  ,@Telefono
		  ,@UserAccessID
		  ,@citizenshipID
		  ,@docNumber
		  ,@docTypeID
		  ,@expirationDate
		  ,@IdDocID OUTPUT

		if @recordDocOnly = 0 --this is a full identification
		begin
			--first start with the registration
			if @importo is not null -- we need to register the transaction
			BEGIN
				--insert or update the existing registration
				execute [Snoopy].[usp_NewLRDRegistration]
					@CustID,
					@IDCauseID,
					@StockID,
					@IdGaming,
					@Importo,
					@UserAccessID,
					0,--do not modify hour
					@note, 
					@RegID output,
					@dummy1 output, --@idDate
					@dummy4 output,--identificID
					@dummy2 output, --@BirthDate
					@RegTime output

			END


			--insert a new identification
			insert into Snoopy.tbl_Identifications
				(
				CustomerID,
				InsertTimeStampUTC,
				GamingDate,
				IdentificationUserAccessID,
				IDDocumentID,
				IDCauseID,
				RegID,
				Note
				)
				Values
				(
				@CustID,
				@IdTime, 
				@IdGaming,
				@UserAccessID,
				@IdDocID,
				@IDCauseID,
				@RegID,
				@spec
				)

			set @IdentificationID = SCOPE_IDENTITY()			

			--finally mark as identified the customer
			update Snoopy.tbl_Customers
				set IdentificationID = @IdentificationID
				where CustomerID = @CustID
		end
	end

	-- in case this cause id justifies his belonging to the golden club
	DECLARE @GoldenClubMemberTypeID INT
	select @GoldenClubMemberTypeID =  GoldenClubMemberTypeID from Snoopy.tbl_IDCauses where IDCauseID = @IDCauseID 
	if @GoldenClubMemberTypeID IS NOT NULL
	and not exists (select CustomerID from GoldenClub.tbl_Members where CustomerID = @CustID)
	begin
		--this is a full identification we have to add him to the golden club
		if @recordDocOnly = 0
		begin
		--in case we identified 
			--insert it into golden club
			declare @dummy datetime
			execute [GoldenClub].[usp_CreateGoldenMember]
				@CustID ,
				@GoldenClubMemberTypeID,
				@UserAccessID,
				@dummy output
		end
	end

	if @IdTime is not null
	begin
		--return the idtime in local hour
		set @IdTime=GeneralPurpose.fn_UTCToLocal(1,@IdTime)
	end


	COMMIT TRANSACTION trn_NewLRDIdentifyCustomer

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDIdentifyCustomer
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
