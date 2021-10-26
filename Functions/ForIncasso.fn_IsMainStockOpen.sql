SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [ForIncasso].[fn_IsMainStockOpen] (@GamingDate datetime)  
RETURNS INT 
WITH SCHEMABINDING
AS  
BEGIN 


/*

declare @GamingDate datetime
set @GamingDate = '3.17.2020'
select [ForIncasso].[fn_IsMainStockOpen] (@GamingDate)

*/
	declare @outVal int
	SELECT @outVal = [ForIncasso].[fn_IsStockOpen] (31,@GamingDate)

	return (@outVal)


END
GO
