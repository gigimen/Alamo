SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [CasinoLayout].[fn_GetCurrentCompositionByGamingDate] (
@GamingDate  DATETIME,@StockID INT)
RETURNS INT
WITH SCHEMABINDING
AS  
BEGIN
	IF @GamingDate IS NULL OR @StockID IS null
		RETURN NULL

	/*
	
	declare @GamingDate  DATETIME,@StockID INT
	
	set @GamingDate  = '1.13.2019'
	set @StockID = 46

	select * FROM [Alamo].[CasinoLayout].[tbl_StockComposition_Stocks] WHERE StockID = @StockID 
	order by StartOfUseGamingDate desc
	--*/ 

	DECLARE @StockCompositionID INT
	/*check if the was a */
	SELECT @StockCompositionID = StockCompositionID 
	FROM CasinoLayout.tbl_StockComposition_Stocks 
	WHERE StockID = @StockID 
	AND StartOfUseGamingDate <=  @GamingDate
	AND
	(
	EndOfUseGamingDate IS NULL --still in use
	OR
    EndOfUseGamingDate >= @GamingDate
	) 

	--select @StockCompositionID AS '@StockCompositionID'

	RETURN @StockCompositionID
END
GO
