SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Managers].[msp_DuplicateComposition]
 @compID INT,
 @startgamingdate DATETIME,
 @nome	varchar(64),
 @desc  VARCHAR(256),
 @newcompID INT OUTPUT
AS

IF NOT EXISTS (SELECT StockCompositionID FROM [CasinoLayout].[StockCompositions] WHERE StockCompositionID = @compID)
BEGIN
	RAISERROR('iNVALID cOMPID (%D) specified',16,1,@compID)
	RETURN 1
end

declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_DuplicateComposition

BEGIN TRY  

/*
declare
 @compID INT,
 @startgamingdate DATETIME,
 @nome	varchar(64),
 @desc  VARCHAR(256),
 @newcompID INT 

		set @compID = 1032
		set @startgamingdate = N'6.30.2021'
		set @nome = N'Piu 100''000 CHF per JP Diamond'
		set @desc = N'Piu 100''000 CHF per JP Diamond'

--*/
	INSERT INTO [CasinoLayout].[StockCompositions]
			   ([FName]
			   ,[FDescription]
			   ,[CreationDate])
	SELECT @nome
		  ,@desc
		  ,GETUTCDATE()
	FROM [CasinoLayout].[StockCompositions]
	WHERE StockCompositionID = @compID

	SET @newcompID = SCOPE_IDENTITY()


	PRINT 'Insert denomination for the new composition ' + CAST(@newcompID AS VARCHAR(16))
	INSERT INTO [CasinoLayout].[StockComposition_Denominations]
			   ([StockCompositionID]
			   ,[DenoID]
			   ,[InitialQty]
			   ,[ModuleValue]
			   ,[WeightInTotal]
			   ,[AutomaticFill]
			   ,[AllowNegative]
			   ,[IsRiserva])
	SELECT @newcompID
		  ,[DenoID]
		  ,[InitialQty]
		  ,[ModuleValue]
		  ,[WeightInTotal]
		  ,[AutomaticFill]
		  ,[AllowNegative]
		  ,[IsRiserva]
	  FROM [CasinoLayout].[StockComposition_Denominations]
	WHERE StockCompositionID = @compID


	--terminate old stock composition definition
	print 'terminate old stock composition definition'
	UPDATE [CasinoLayout].[tbl_StockComposition_Stocks]
	   SET [EndOfUseGamingDate] = DATEADD(DAY,-1,@startgamingdate)
	WHERE StockCompositionID = @compID AND EndOfUseGamingDate IS null

/*


SET IDENTITY_INSERT CasinoLayout.tbl_StockComposition_Stocks ON
INSERT INTO [CasinoLayout].[tbl_StockComposition_Stocks]
           (PrimKeyID,
		   [StockCompositionID]
           ,[StockID]
           ,[StartOfUseGamingDate]
           ,[EndOfUseGamingDate])
     VALUES
           (588,1034
           ,46
           ,'6.30.2021'
           ,NULL)

SET IDENTITY_INSERT CasinoLayout.tbl_StockComposition_Stocks OFF

*/	
	print 'link stock to new composition'
	INSERT INTO [CasinoLayout].[tbl_StockComposition_Stocks]
			   (
			   [StockCompositionID]
			   ,[StockID]
			   ,[StartOfUseGamingDate])
	SELECT @newcompID
		  ,[StockID]
		  ,@startgamingdate
	FROM [CasinoLayout].[tbl_StockComposition_Stocks]
	WHERE StockCompositionID = @compID

	COMMIT TRANSACTION trn_DuplicateComposition

END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_DuplicateComposition
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

return @ret	

GO
