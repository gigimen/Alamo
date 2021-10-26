SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [Managers].[msp_HandleError] 
	@dove as varchar(50)
AS 
BEGIN   
	INSERT INTO [Managers].[tbl_Errors] ([Dove]) VALUES( @dove)

	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );

END
GO
GRANT EXECUTE ON  [Managers].[msp_HandleError] TO [CKeyUsage]
GO
GRANT EXECUTE ON  [Managers].[msp_HandleError] TO [FloorUsage]
GO
GRANT EXECUTE ON  [Managers].[msp_HandleError] TO [GoldenClubUsage]
GO
GRANT EXECUTE ON  [Managers].[msp_HandleError] TO [TecRole]
GO
