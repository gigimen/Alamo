SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [GoldenClub].[usp_EnterConsegnaPromozione]
@CustID 		int,
@PromotionID	int,
@PremioID		int,
@useraccessid	int,
@gamingdate		datetime
AS


if not exists (
select UserAccessID from FloorActivity.tbl_UserAccesses 
where UserAccessID = @UserAccessID 
--and UserGroupID in(10,6) --capo cassiera & shifts only
)
begin
	raiserror('Invalid UserAccessID (%d) specified ',16,1,@UserAccessID)
	return 1
end


declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_EnterConsegnaPromozione

BEGIN TRY  




	EXECUTE [GoldenClub].[usp_CheckConsegnaPromozione] 
	   @CustID
	  ,@PromotionID
	  ,@PremioID
	  ,@gamingdate




	--piazza l'ordine
	INSERT INTO Marketing.tbl_ConsegnaPromozione
           ([PremioID]
           ,[CustomerID]
           ,[GamingDate]
           ,[UserAccessID]
           ,[PromotionID])
     VALUES
           (@PremioID
           ,@CustID
           ,@gamingdate
           ,@UserAccessID
           ,@PromotionID)


	COMMIT TRANSACTION trn_EnterConsegnaPromozione

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_EnterConsegnaPromozione
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
