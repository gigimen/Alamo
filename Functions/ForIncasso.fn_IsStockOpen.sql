SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [ForIncasso].[fn_IsStockOpen] (@stockID INT,@GamingDate DATETIME)  
RETURNS INT 
WITH SCHEMABINDING
AS  
BEGIN 


/*

declare @GamingDate datetime
set @GamingDate = '3.17.2020'
select [ForIncasso].[fn_IsStockOpen] (31,@GamingDate)

*/
	DECLARE @outVal INT
	SELECT @outVal = ISNULL(CloseSnapshotID,0)
	FROM [Accounting].[vw_AllStockLifeCycles] 
	WHERE StockID = @stockID AND [GamingDate] = @GamingDate

	IF @outVal IS NULL
		SET @outVal = -1

	RETURN (@outVal)


END
GO
