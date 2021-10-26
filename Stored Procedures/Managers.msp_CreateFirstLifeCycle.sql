SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE  [Managers].[msp_CreateFirstLifeCycle]
@StockID INT,
@gaming DATETIME,
 @tUTC DATETIME OUTPUT,
 @tLoc DATETIME output

AS
/*

declare @StockID int
declare @SourceUserAccessID int
set @StockID = 53
set @SourceUserAccessID = 1
*/
declare @ret int
set @ret = 0

BEGIN TRANSACTION trn_CreateFirstLifeCycle


BEGIN TRY  

	DEClare @lfcyID INT
	DEClare @LFSSID INT
	declare @StockTypeID int
	declare @StockCompositionID INT
	DECLARE @Tag VARCHAR(16)

	if EXISTS(SELECT LifeCycleID FROM Accounting.tbl_LifeCycles WHERE StockID = @StockID)
	begin
		raiserror('Stock %d has already 1 lifecycle defined',16,1,@StockID)
		return (1)
	end
	--get StockTypeID and @InitialReserve
	select @StockTypeID = StockTypeID,@Tag=Tag
	from CasinoLayout.Stocks 
	where StockID = @StockID

	--get current StockCompositionID for the specified stock 
	select @StockCompositionID = StockCompositionID 
	from CasinoLayout.[tbl_StockComposition_Stocks] 
	where StockID = @StockID AND EndOfUseGamingDate IS null

	if @StockCompositionID is null
	begin
		raiserror('Stock %d has no StockComposition defined',16,1,@StockID)
		return (1)
	end

	print 'Open stock life cycle'
	--open main stock lifecycle

	--print 'Creating life cycle id'
	insert into Accounting.tbl_LifeCycles 
		(StockID,GamingDate,StockCompositionID) 
		VALUES (@StockID,@Gaming,@StockCompositionID)

	SET @lfcyID = SCOPE_IDENTITY()

	EXECUTE Accounting.usp_CreateSnapShotXML 
		@lfcyID,
		1,
		NULL,
		NULL,
		1, --APERTURA
		NULL, --values never stored in apertura!!!
		@LFSSID	output,
		@tLoc output,
		@tUTC output


	PRINT 'Create Chiusura snapshot the stock lifecycle ' + STR(@StockID)
	EXEC @ret = Accounting.usp_CreateSnapShotXML
			@lfcyID,				--@LifeCycleID		int,
			1,		--@UserAccessID		int,
			NULL,						--@ConfUserID			INT,
			NULL,						--@ConfUserGroupID	int,
			3,							--@SSTypeID			INT,
			NULL,						--@values				varchar(max),
			@LFSSID OUTPUT,		--	@SnapshotID			INT output,
			@tLoc OUTPUT,				--	@SnapshotTimeLoc	datetime output,
			@tUTC OUTPUT				--	@SnapshotTimeUTC	datetime output	

	COMMIT TRANSACTION trn_CreateFirstLifeCycle
END TRY  
BEGIN CATCH  
	ROLLBACK TRANSACTION trn_CreateFirstLifeCycle
	set @ret = error_number()
	declare @dove as varchar(50)
	select @dove = OBJECT_SCHEMA_NAME(@@PROCID)+'.'+OBJECT_NAME(@@PROCID)
	EXEC [Managers].[msp_HandleError] @dove
END CATCH

GO
