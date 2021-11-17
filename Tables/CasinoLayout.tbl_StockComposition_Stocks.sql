CREATE TABLE [CasinoLayout].[tbl_StockComposition_Stocks]
(
[PrimKeyID] [int] NOT NULL IDENTITY(1, 1),
[StockCompositionID] [int] NOT NULL,
[StockID] [int] NOT NULL,
[StartOfUseGamingDate] [datetime] NOT NULL,
[EndOfUseGamingDate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [CasinoLayout].[trg_CheckOverlapTimeAtInsert] ON [CasinoLayout].[tbl_StockComposition_Stocks] 
INSTEAD OF INSERT
AS
BEGIN

    IF NOT EXISTS(
        SELECT 1
        FROM INSERTED
    ) 
	begin
		RAISERROR('NO ROW IN INSERT', 16, 1)
		return
	end
	SET NOCOUNT ON;
    SET XACT_ABORT ON;

	DECLARE @PrimKeyID INT
    DECLARE @ConflictPrimKeyID int
	declare @StockCompositionID int
	declare @StockID int
	declare @StartOfUseGamingDate datetime
	declare @EndOfUseGamingDate datetime

    DECLARE cur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
		SELECT i.[PrimKeyID]
			  ,i.[StockCompositionID]
			  ,i.[StockID]
			  ,i.[StartOfUseGamingDate]
			  ,i.[EndOfUseGamingDate]
        FROM INSERTED i

    OPEN cur

    FETCH NEXT FROM cur INTO
		 @PrimKeyID
        , @StockCompositionID 
        , @StockID 
        , @StartOfUseGamingDate 
        , @EndOfUseGamingDate 

    WHILE @@FETCH_STATUS = 0
    BEGIN


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
		IF @ConflictPrimKeyID IS NOT null
		begin
			raiserror('INSERT: There is already an active stockcomposition(%d) for stock(%d) PRIMKEY(%d)',16,1,@StockCompositionID,@StockID,@ConflictPrimKeyID)
			RETURN
		END
	END

	IF @EndOfUseGamingDate IS NOT NULL AND @StartOfUseGamingDate IS NOT NULL AND  @StartOfUseGamingDate > @EndOfUseGamingDate
	begin
		DECLARE @t varchar(1024)
		SELECT @t = 'Start(' + CONVERT(VARCHAR(32),@StartOfUseGamingDate,103) + ') End(' + CONVERT(VARCHAR(32),@EndOfUseGamingDate,103) +')'
		raiserror('INSERT: Time interval badly defined for PRIMKEY(%d) %s',16,1,@PrimKeyID,@t)
		RETURN
	END

	--make sure there is no time overlap with another stockcomposition with the 
	--specified @EndOfUseGamingDate
	IF @EndOfUseGamingDate IS NOT NULL 
	begin
		SELECT  @ConflictPrimKeyID =  [PrimKeyID]
		FROM [CasinoLayout].[tbl_StockComposition_Stocks] 
		WHERE @StockID = [StockID] AND @PrimKeyID <> [PrimKeyID]
		--@EndOfUseGamingDate falls into an existing time interval
		AND @EndOfUseGamingDate >= [StartOfUseGamingDate]	
		AND (
			[EndOfUseGamingDate] IS NULL OR 
			([EndOfUseGamingDate] IS NOT NULL AND [EndOfUseGamingDate] >= @EndOfUseGamingDate)
			)
		IF @ConflictPrimKeyID IS NOT null
		begin
			raiserror('INSERT: @EndOfUseGamingDate falls into an existing time interval defined in @PrimKeyID(%d)',16,1,@ConflictPrimKeyID)
			RETURN
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
	IF @ConflictPrimKeyID IS NOT null
	begin
		raiserror('INSERT: @StartOfUseGamingDate falls into an existing time interval  defined in @PrimKeyID(%d)',16,1,@ConflictPrimKeyID)
		RETURN
	END

	
	INSERT INTO [CasinoLayout].[tbl_StockComposition_Stocks]
			   ([StockCompositionID]
			   ,[StockID]
			   ,[StartOfUseGamingDate]
			   ,[EndOfUseGamingDate])
		 VALUES
		( @StockCompositionID 
        , @StockID 
        , @StartOfUseGamingDate 
        , @EndOfUseGamingDate )


    FETCH NEXT FROM cur INTO
		 @PrimKeyID
        , @StockCompositionID 
        , @StockID 
        , @StartOfUseGamingDate 
        , @EndOfUseGamingDate 

    END

    CLOSE cur
    DEALLOCATE cur

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [CasinoLayout].[trg_CheckOverlapTimeAtUpdate] ON [CasinoLayout].[tbl_StockComposition_Stocks] 
INSTEAD OF UPDATE
AS
BEGIN

    IF NOT EXISTS(
        SELECT 1
        FROM INSERTED
    ) 
	begin
		RAISERROR('NO ROW IN UPDATE', 16, 1)
		return
	end
 /*   SET NOCOUNT ON;
    SET XACT_ABORT ON;
*/
	DECLARE @PrimKeyID int
	DECLARE @ConflictPrimKeyID int
	declare @StockCompositionID int
	declare @StockID int
	declare @StartOfUseGamingDate datetime
	declare @EndOfUseGamingDate datetime

    DECLARE cur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
		SELECT i.[PrimKeyID]
			  ,i.[StockCompositionID]
			  ,i.[StockID]
			  ,i.[StartOfUseGamingDate]
			  ,i.[EndOfUseGamingDate]
        FROM INSERTED i

    OPEN cur

    FETCH NEXT FROM cur INTO
		 @PrimKeyID
        , @StockCompositionID 
        , @StockID 
        , @StartOfUseGamingDate 
        , @EndOfUseGamingDate 

    WHILE @@FETCH_STATUS = 0
    BEGIN

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
		IF @ConflictPrimKeyID IS NOT null
		begin
			raiserror('UPDATE: There is already an active stockcomposition(%d) for stock(%d) PRIMKEY(%d)',16,1,@StockCompositionID,@StockID,@ConflictPrimKeyID)
			RETURN
		END
	END

	IF @EndOfUseGamingDate IS NOT NULL AND @StartOfUseGamingDate IS NOT NULL AND  @StartOfUseGamingDate > @EndOfUseGamingDate
	BEGIN
		DECLARE @t varchar(1024)
		SELECT @t = 'Start(' + CONVERT(VARCHAR(32),@StartOfUseGamingDate,103) + ') End(' + CONVERT(VARCHAR(32),@EndOfUseGamingDate,103) +')'
		raiserror('UPDATE: Time interval badly defined for PRIMKEY(%d) %s',16,1,@PrimKeyID,@t)
		RETURN
	END

	--make sure there is no time overlap with another stockcomposition with the 
	--specified @EndOfUseGamingDate
	IF @EndOfUseGamingDate IS NOT NULL 
	begin
		SELECT  @ConflictPrimKeyID =  [PrimKeyID]
		FROM [CasinoLayout].[tbl_StockComposition_Stocks] 
		WHERE @StockID = [StockID] AND @PrimKeyID <> [PrimKeyID]
		--@EndOfUseGamingDate falls into an existing time interval
		AND @EndOfUseGamingDate >= [StartOfUseGamingDate]	
		AND (
			[EndOfUseGamingDate] IS NULL OR 
			([EndOfUseGamingDate] IS NOT NULL AND [EndOfUseGamingDate] >= @EndOfUseGamingDate)
			)
		IF @ConflictPrimKeyID IS NOT null
		begin
			raiserror('UPDATE: @EndOfUseGamingDate falls into an existing time interval defined in @PrimKeyID(%d)',16,1,@ConflictPrimKeyID)
			RETURN
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
	IF @ConflictPrimKeyID IS NOT null
	begin
		raiserror('UPDATE: @StartOfUseGamingDate falls into an existing time interval  defined in @PrimKeyID(%d)',16,1,@ConflictPrimKeyID)
		RETURN
	END

	UPDATE [CasinoLayout].[tbl_StockComposition_Stocks]
	   SET [StockCompositionID]		= @StockCompositionID 
		  ,[StockID]				= @StockID 
		  ,[StartOfUseGamingDate]	= @StartOfUseGamingDate 
		  ,[EndOfUseGamingDate]		= @EndOfUseGamingDate 
	WHERE @PrimKeyID = [PrimKeyID]

    FETCH NEXT FROM cur INTO
		 @PrimKeyID
        , @StockCompositionID 
        , @StockID 
        , @StartOfUseGamingDate 
        , @EndOfUseGamingDate 

    END

    CLOSE cur
    DEALLOCATE cur

END
GO
ALTER TABLE [CasinoLayout].[tbl_StockComposition_Stocks] ADD CONSTRAINT [PK_StockComposition_Stocks] PRIMARY KEY CLUSTERED  ([PrimKeyID]) ON [PRIMARY]
GO
ALTER TABLE [CasinoLayout].[tbl_StockComposition_Stocks] ADD CONSTRAINT [FK_StockComposition_Stocks_StockCompositions] FOREIGN KEY ([StockCompositionID]) REFERENCES [CasinoLayout].[StockCompositions] ([StockCompositionID])
GO
ALTER TABLE [CasinoLayout].[tbl_StockComposition_Stocks] ADD CONSTRAINT [FK_StockComposition_Stocks_Stocks] FOREIGN KEY ([StockID]) REFERENCES [CasinoLayout].[Stocks] ([StockID])
GO
