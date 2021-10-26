SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



/****** Object:  StoredProcedure [dbo].[usp_CreateTransaction]    Script Date: 07/19/2012 14:09:54 ******/
--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_NewFornitore] 
@FornitoreDescription	varchar(128),
@Facility				bit,
@FornitoreID			int output
AS
DECLARE @err int
if @FornitoreDescription is null or len(@FornitoreDescription ) = 0
begin
	raiserror('Invalid FornitoreDescription specified ',16,1)
	return 1
end

if exists (
select FornitoreID from Techs.Fornitori 
where [FornitoreDescription] = @FornitoreDescription
and Facility = @Facility
)
begin
	raiserror('Il Fornitore %s già esiste',16,1,@FornitoreDescription)
	return 3
end


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_NewFornitore
BEGIN TRY  




	INSERT INTO [Techs].[Fornitori]
			   ([FornitoreDescription]
			   ,[Facility])
		 VALUES
			   (@FornitoreDescription
			   ,@Facility)


		SELECT @err = @@error IF @err <> 0   begin		ROLLBACK TRANSACTION CreateFornitore		RETURN @err 	end

		set @FornitoreID = SCOPE_IDENTITY()


	COMMIT TRANSACTION trn_NewFornitore

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_NewFornitore
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret


GO
