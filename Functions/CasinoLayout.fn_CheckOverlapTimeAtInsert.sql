SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [CasinoLayout].[fn_CheckOverlapTimeAtInsert] 
(
@PrimKeyID INT
) 
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @ret VARCHAR(64)
    IF NOT EXISTS(
        SELECT PrimKeyID
        FROM [CasinoLayout].[tbl_StockComposition_Stocks]
		WHERE PrimKeyID=@PrimKeyID
    ) 
	begin
		SET @ret = 'NO ROW selected'
		RETURN @ret
	END

    DECLARE @ConflictPrimKeyID int
	declare @StockCompositionID int
	declare @StockID int
	declare @StartOfUseGamingDate datetime
	declare @EndOfUseGamingDate datetime

		SELECT @StockCompositionID =i.[StockCompositionID]
			  ,@StockID =i.[StockID]
			  ,@StartOfUseGamingDate=i.[StartOfUseGamingDate]
			  ,@EndOfUseGamingDate=i.[EndOfUseGamingDate]
        FROM [CasinoLayout].[tbl_StockComposition_Stocks] i
		WHERE PrimKeyID=@PrimKeyID
 

	SET @ConflictPrimKeyID = null
	--make sure ther is not another active stockcomposition
	IF @EndOfUseGamingDate IS NULL 
	BEGIN
		--check there is another stock composition for that StockID with no end defined 
		SELECT @ConflictPrimKeyID = [PrimKeyID] 
		FROM [CasinoLayout].[tbl_StockComposition_Stocks] 
		WHERE 
			@StockID =[StockID] 
			AND @PrimKeyID <> [PrimKeyID] 
			AND EndOfUseGamingDate IS null
		IF @ConflictPrimKeyID IS NOT NULL
		BEGIN
			SET @ret = 'Primkey ' + CAST(@ConflictPrimKeyID AS VARCHAR(8)) + 'There is already an active stockcomposition PRIMKEY ' + CAST(@ConflictPrimKeyID AS VARCHAR(8))
			RETURN @ret
		END
	END

	IF @EndOfUseGamingDate IS NOT NULL AND @StartOfUseGamingDate IS NOT NULL AND  @StartOfUseGamingDate > @EndOfUseGamingDate
	begin
		SET @ret = 'Time interval badly defined for PRIMKEY '+ CAST(@PrimKeyID AS VARCHAR(8))
		RETURN @ret
	END

	--make sure there is no time overlap with another stockcomposition with the 
	--specified @EndOfUseGamingDate
	IF @EndOfUseGamingDate IS NOT NULL 
	BEGIN
		SELECT  @ConflictPrimKeyID =  [PrimKeyID]
		FROM [CasinoLayout].[tbl_StockComposition_Stocks] 
		WHERE @StockID = [StockID] AND @PrimKeyID <> [PrimKeyID]
		--@EndOfUseGamingDate falls into an existing time interval
		AND @EndOfUseGamingDate >= [StartOfUseGamingDate]	
		AND (
			[EndOfUseGamingDate] IS NULL OR 
			([EndOfUseGamingDate] IS NOT NULL AND [EndOfUseGamingDate] >= @EndOfUseGamingDate)
			)
		IF @ConflictPrimKeyID IS NOT NULL
		BEGIN
			SET @ret = 'Primkey ' + CAST(@PrimKeyID AS VARCHAR(8)) + ' @EndOfUseGamingDate falls into an existing time interval defined in @PrimKeyID '+ CAST(@ConflictPrimKeyID AS VARCHAR(8))
			RETURN @ret
		END

	END

	--make sure there is no time overlap with another stockcomposition with the 
	--specified @StartOfUseGamingDate
	SELECT @ConflictPrimKeyID = [PrimKeyID] 
	FROM [CasinoLayout].[tbl_StockComposition_Stocks] 
	WHERE @StockID = [StockID] AND @PrimKeyID <> [PrimKeyID]
	--@StartOfUseGamingDate falls into an existing time interval
	AND @StartOfUseGamingDate >= [StartOfUseGamingDate]	
	AND (
		[EndOfUseGamingDate] IS NULL OR 
		([EndOfUseGamingDate] IS NOT NULL AND [EndOfUseGamingDate] >= @StartOfUseGamingDate)
		)
	IF @ConflictPrimKeyID IS NOT NULL
	BEGIN
		SET @ret = 'Primkey ' + CAST(@PrimKeyID AS VARCHAR(8)) + ' @StartOfUseGamingDate falls into an existing time interval defined in @PrimKeyID '+ CAST(@ConflictPrimKeyID AS VARCHAR(8))
		RETURN @ret
	END

	IF @EndOfUseGamingDate IS NOT NULL
    BEGIN
		
		SELECT @StartOfUseGamingDate = MIN(StartOfUseGamingDate)
		FROM [CasinoLayout].[tbl_StockComposition_Stocks] 
		WHERE @StockID = [StockID] AND @EndOfUseGamingDate < StartOfUseGamingDate

		IF @StartOfUseGamingDate IS NOT NULL
        BEGIN
			SELECT @ConflictPrimKeyID = [PrimKeyID] 
			FROM [CasinoLayout].[tbl_StockComposition_Stocks] 
			WHERE @StartOfUseGamingDate = StartOfUseGamingDate AND StockID = @StockID

			IF DATEDIFF(DAY,@EndOfUseGamingDate,@StartOfUseGamingDate) > 1
			BEGIN
				SET @ret = 'Primkey ' + CAST(@PrimKeyID AS VARCHAR(8)) + ' time gap of ' + CAST( DATEDIFF(DAY,@EndOfUseGamingDate,@StartOfUseGamingDate) AS VARCHAR(16)) +' days WITH @PrimKeyID '+ CAST(@ConflictPrimKeyID AS VARCHAR(8))
				RETURN @ret
			END

		END
	END
	SET @ret = 'ok'
		RETURN @ret
END
GO
