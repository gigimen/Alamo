SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--SET ANSI_WARNINGS ON
--SET ANSI_NULLS ON 
--SET QUOTED_IDENTIFIER OFF

CREATE procedure [Techs].[usp_DeleteRimborso] 
@InterventoID		INT,
@UserAccessID		INT
AS

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DeleteRimborso

BEGIN TRY  

	--delete rimborso
	IF EXISTS (SELECT InterventoID FROM [Techs].[Rimborsi] WHERE InterventoID = @InterventoID)
	BEGIN
	    --find shortpay in Accounting system
		DECLARE @slottransid INT
		SELECT 	@slottransid = SlotTransactionID FROM Accounting.tbl_SlotTransactions WHERE InterventoID = @InterventoID
		IF @slottransid IS NOT NULL
        BEGIN			
				EXECUTE [Accounting].[usp_DeleteSlotTransaction]
					@slottransID ,
					@UserAccessID 
		end
		DELETE FROM [Techs].[Rimborsi]  WHERE InterventoID = @InterventoID
	END

	COMMIT TRANSACTION trn_DeleteRimborso

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DeleteRimborso
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
