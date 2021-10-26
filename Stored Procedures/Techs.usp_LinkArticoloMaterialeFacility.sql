SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF


CREATE procedure [Techs].[usp_LinkArticoloMaterialeFacility] 
@FacilityID				INT,
@FornitoreID			INT,
@ArticoloDescription	VARCHAR(256),
@NumPezzi				INT
AS

if not exists(select MaterialeFacilityID from Techs.MaterialeFacility where MaterialeFacilityID = @FacilityID)
begin
	raiserror('Invalid FacilityID (%d) specified ',16,1,@FacilityID)
	return 1
end


if @fornitoreID is NULL OR NOT exists (SELECT FornitoreID FROM techs.Fornitori WHERE FornitoreID = @FornitoreID AND Facility = 1)
begin
	raiserror('Invalid FornitoreID (%d) specified ',16,1,@FornitoreID)
	return 1
END

IF @ArticoloDescription IS NULL OR LEN (@ArticoloDescription) = 0
begin
	raiserror('Invalid ArticoloDescription specified ',16,1)
	return 1
END

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_LinkArticoloFacility

BEGIN TRY  



	if not exists (
	select FornitoreID 
	from Techs.MaterialeFacility_Articoli 
	where FornitoreID = @FornitoreID 
	and MaterialeFacilityID = @FacilityID
	AND [DescrizioneArticolo] = @ArticoloDescription
	)
	begin 	

		INSERT INTO Techs.MaterialeFacility_Articoli
			   (MaterialeFacilityID
			   ,[FornitoreID]
			   ,[NumPezzi]
			   ,[DescrizioneArticolo])
		 VALUES
 
			   (@FacilityID
			   ,@FornitoreID
			   ,@NumPezzi
			   ,@ArticoloDescription)

	
	end
	else
	begin

		UPDATE Techs.MaterialeFacility_Articoli
		SET [NumPezzi] = @NumPezzi
		where FornitoreID = @FornitoreID 
		and MaterialeFacilityID = @FacilityID
		AND [DescrizioneArticolo] = @ArticoloDescription



	end

	COMMIT TRANSACTION trn_LinkArticoloFacility

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_LinkArticoloFacility
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret



GO
