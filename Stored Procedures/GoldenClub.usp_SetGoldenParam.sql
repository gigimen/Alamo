SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROCEDURE [GoldenClub].[usp_SetGoldenParam] 
@customerID INT,
@paramIndex	INT
AS
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_SetGoldenParam

BEGIN TRY  



	UPDATE GoldenClub.tbl_Members 
		SET GoldenParams = GoldenParams | @paramIndex
	WHERE CustomerID = @CustomerID 


	COMMIT TRANSACTION trn_SetGoldenParam

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_SetGoldenParam
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret
GO
