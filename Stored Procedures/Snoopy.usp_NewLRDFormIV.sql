SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Snoopy].[usp_NewLRDFormIV]
@CustID 	int,
@UserAccessID 	int,
@ColloquioGamingDate datetime output,
@ChiarimentoID int output,
@FormIVTime	datetime output
AS


set @ColloquioGamingDate = null
set @FormIVTime	= null

--check input values
if @UserAccessID is null
begin
	raiserror('Invalid user access specified',16,1)
	return (1)
end

if @CustID is null or not exists (select IdentificationID from Snoopy.tbl_Identifications i where i.CustomerID = @custID)
begin
	raiserror('Invalid CustomerId (%d) specified or customer not identified',16,1,@custID)
	return(1)
end

declare @IdentificationID int

--check if already identified
select 	@IdentificationID = c.IdentificationID
from Snoopy.tbl_Customers c
where c.CustomerID = @CustID

if @IdentificationID is null
begin
	raiserror('Customer must be identified first',16,1)
	return (3)
end


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDFormIV

BEGIN TRY  



	--check if exist already an entry in table chiarimenti
	select 	@IdentificationID = i.IdentificationID,
		@ChiarimentoID = i.ChiarimentoID,
		@ColloquioGamingDate = ch.ColloquioGamingDate,
		@FormIVTime	= ch.FormIVTimeLoc
	from Snoopy.tbl_Identifications i 
	left outer join Snoopy.tbl_Chiarimenti ch 
	on ch.ChiarimentoID = i.ChiarimentoID
	where i.IdentificationID = @IdentificationID 

	set @FormIVTime = GetDate()

	if @ChiarimentoID is null
	begin --we have to create a new chiarimento

		insert into Snoopy.tbl_Chiarimenti
		(CustomerID,FormIVTimeLoc,FormIVUserAccessID)
		values
		(@CustID,@FormIVTime,@UserAccessId)


		set @ChiarimentoID = SCOPE_IDENTITY()
		UPDATE Snoopy.tbl_Identifications
			SET ChiarimentoID= @ChiarimentoID
		WHERE	IdentificationID = @IdentificationID	

	end
	else
	begin
		--just update an existing chiarimento
		update Snoopy.tbl_Chiarimenti
		set CustomerID = @CustID,
			FormIVTimeLoc = @FormIVTime,
			FormIVUserAccessID = @UserAccessId
		WHERE	ChiarimentoID= @ChiarimentoID	

	end


	COMMIT TRANSACTION trn_NewLRDFormIV

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDFormIV
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
