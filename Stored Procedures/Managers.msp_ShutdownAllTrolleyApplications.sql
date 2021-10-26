SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Managers].[msp_ShutdownAllTrolleyApplications] 
AS

DECLARE	@return_value int

		--shutdown all cassa application
EXEC	@return_value = [Managers].[msp_ShutdownComputerApplications]
		@CompName = null,--'ws-cassa3',
		@Appid = 70195

SELECT	'Return Value' = @return_value



		--shutdown all trolleymngapp application
EXEC	@return_value = [Managers].[msp_ShutdownComputerApplications]
		@CompName = null,--'ws-cassa3',
		@Appid = 220401

SELECT	'Return Value' = @return_value



		--shutdown all trolleymngapp application
EXEC	@return_value = [Managers].[msp_ShutdownComputerApplications]
		@CompName = null,--'ws-cassa3',
		@Appid = 250445

SELECT	'Return Value' = @return_value


GO
