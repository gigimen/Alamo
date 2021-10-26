SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_GetLastDifferenzeDiCassa] 
AS
/*
execute [Accounting].[usp_GetLastDifferenzeDiCassa] 
*/
DECLARE @gamingdate DATETIME

SELECT @gamingdate = DATEADD(DAY,-1,[GeneralPurpose].[fn_GetGamingDate] (GETDATE(),0,4))
execute [Accounting].[usp_GetAllDifferenzeDiCassa] @gamingdate
GO
