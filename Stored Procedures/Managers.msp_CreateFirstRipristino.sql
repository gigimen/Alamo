SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE  [Managers].[msp_CreateFirstRipristino]
@StockID INT,
@SourceUserAccessID INT
AS
/*

declare @StockID int
declare @SourceUserAccessID int
set @StockID = 53
set @SourceUserAccessID = 1
*/
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateFirstRipristino


BEGIN TRY  

	declare @StockTypeID int
	select @StockTypeID = StockTypeID from CasinoLayout.Stocks where StockID = @StockID
	declare @MSlfcyID int
	declare @MSLFSSID int
	declare @g datetime
	declare @tUTC datetime
	declare @tLoc datetime

	if not exists( select LifeCycleID from Accounting.tbl_LifeCycles where StockID = 31)
	begin
		print 'Create Main stock life cycle'
		--open main stock lifecycle
		execute @ret = Accounting.usp_OpenLifeCycle 31,1,null,null,@MSlfcyID output,@MSLFSSID output,@g output,
			@tLoc output,
			@tUTC output
	END
	ELSE
	BEGIN
		select @MSlfcyID = (LifeCycleID) from [Accounting].[fn_GetLastLifeCycleByStock] (GETDATE(),31)
		select @MSLFSSID = LifeCycleSnapshotID from Accounting.tbl_Snapshots where LifeCycleID = @MSlfcyID and SnapshotTypeID = 1
		PRINT 'Main stock lifecycle id: ' + STR(@MSlfcyID) 
	END
	declare @stocklfcyID int
	declare @stockLFSSID int
	--if not a main stock open a new life cycle
	if @StockTypeID not in (select StockTypeID from CasinoLayout.StockTypes where FDescription = 'Main Stocks' )
	begin
		print 'Open the stock ' + str(@StockID)
		EXEC @ret = Accounting.usp_OpenLifeCycle 
			@StockID,
			@SourceUserAccessID,
			null,
			null,
			@stocklfcyID output,
			@stockLFSSID output,
			@g output,
			@tLoc output,
			@tUTC output
	END
	ELSE
	BEGIN
		set @stocklfcyID = @MSlfcyID
		SET @stockLFSSID = @MSLFSSID
	END
	--for trolleys and main trolleys create also the consegna and rispristino
	IF @StockTypeID IN (4,7)
	BEGIN
		print 'create Consegna for stock ' + str(@StockID)
		INSERT INTO Accounting.tbl_Transactions 
			(
				OpTypeID,
				SourceLifeCycleID,
				SourceUserAccessID,
				SourceTime,
				DestStockTypeID,
				DestStockID,
				DestLifeCycleID,
				DestTime
			) 
			VALUES
			( 
				5, --ConsegnaPerRipristino
				@stocklfcyID,
				@SourceUserAccessID,
				GetUTCDATE(),
				2, --MS StockTypeID
				31, --MS StockID
				@MSlfcyID,
				GetUTCDATE()
			)

		print 'create ripristino for stock ' + str(@StockID)
		INSERT INTO Accounting.tbl_Transactions 
				(
					OpTypeID,
					SourceLifeCycleID,
					DestStockTypeID,
					DestStockID,
					SourceUserAccessID,
					SourceTime
				) 
				VALUES
				( 
					6,--Ripristino
					@MSlfcyID,
					@StockTypeID,
					@StockID,
					@SourceUserAccessID,
					GETUTCDATE()
				)

		IF @StockTypeID IN (7) --main trolleys
		BEGIN
			--create one 200'000 € for cassa cenrale ripristino
			INSERT INTO Accounting.tbl_TransactionValues
				(
					TransactionID,
					DenoID,
					Quantity,
					CashInbound,
					ExchangeRate
				) 
				VALUES
				( 
					@@IDENTITY,
					31,	--Euro da 500
					400,	--400 pieces of 500 € to make 200'000 €
					1,
					1.53	--this may vary
				)
		END

	END
	PRINT 'create Chiusura snapshot the stock lifecycle ' + STR(@stocklfcyID)
	EXEC @ret = Accounting.usp_CreateSnapShotXML
			@stocklfcyID,				--@LifeCycleID		int,
			@SourceUserAccessID,		--@UserAccessID		int,
			NULL,						--@ConfUserID			INT,
			NULL,						--@ConfUserGroupID	int,
			3,							--@SSTypeID			INT,
			NULL,						--@values				varchar(max),
			@stockLFSSID OUTPUT,		--	@SnapshotID			INT output,
			@tLoc OUTPUT,				--	@SnapshotTimeLoc	datetime output,
			@tUTC OUTPUT				--	@SnapshotTimeUTC	datetime output	

	COMMIT TRANSACTION trn_CreateFirstRipristino
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateFirstRipristino
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

GO
