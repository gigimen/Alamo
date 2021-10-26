SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Snoopy].[usp_NewLRDColloquioChiarimento]
@CustID 	int,
@UserAccessID 	int,
@attprof	varchar(1024),
@provVal	varchar(1024),
@altreInfo	varchar(1024),
@ColloquioTime datetime output,
@ColloquioGamingDate datetime output,
@ChiarimentoID int output,
@FormIVTime	datetime output
AS

set @ColloquioGamingDate = null
set @ColloquioTime = null
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

IF @attprof IS NULL SET @attprof = ''
IF @provVal IS NULL SET @provVal = ''
IF @altreInfo IS NULL SET @altreInfo = ''




declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewLRDColloquio

BEGIN TRY  




	--check if exist already a Colloquio
	select 	@IdentificationID = i.IdentificationID,
		@ChiarimentoID = i.ChiarimentoID,
		@ColloquioTime = ch.ColloquioTimeUTC,
		@ColloquioGamingDate = ch.ColloquioGamingDate,
		@FormIVTime	= ch.FormIVTimeLoc
	from Snoopy.tbl_Identifications i 
	left outer join Snoopy.tbl_Chiarimenti ch 
	on ch.ChiarimentoID = i.ChiarimentoID
	where i.IdentificationID = @IdentificationID 

	set @ColloquioTime = GetUTCDate()
	set @ColloquioGamingDate = [GeneralPurpose].[fn_GetGamingLocalDate2](
		@ColloquioTime,
		Datediff(hh,@ColloquioTime,GeneralPurpose.fn_UTCToLocal(1,@ColloquioTime)),
		4 --Trolleys
		)

	if @ChiarimentoID is null
	begin --we have to create a new Colloquio

		insert into Snoopy.tbl_Chiarimenti
		(CustomerID,AttivitaProf,ProvenienzaPatr,AltreInfo,ColloquioUserAccessID,ColloquioTimeUTC,ColloquioGamingDate)
		values
		(@CustID,@attprof,@provVal,@altreInfo,@UserAccessID,@ColloquioTime,@ColloquioGamingDate)

		set @ChiarimentoID = SCOPE_IDENTITY()

		UPDATE Snoopy.tbl_Identifications
			SET ChiarimentoID= @ChiarimentoID
		WHERE	IdentificationID = @IdentificationID	
	
	end
	else
	begin
		--just update an existing Colloquio
		update Snoopy.tbl_Chiarimenti
		set 	CustomerID = @CustID,
			ColloquioTimeUTC = @ColloquioTime,
			ColloquioGamingDate = @ColloquioGamingDate,
			ColloquioUserAccessID = @UserAccessId,
			AttivitaProf = @attprof,
			ProvenienzaPatr = @provVal,
			AltreInfo = @altreInfo
		WHERE	ChiarimentoID= @ChiarimentoID	
	end


	--extract the gaming date
	if @ColloquioTime is not null
	begin
		set @ColloquioTime = GeneralPurpose.fn_UTCToLocal(1,@ColloquioTime)
	end

	COMMIT TRANSACTION trn_NewLRDColloquio

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewLRDColloquio
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
