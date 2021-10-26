SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [Accounting].[usp_GetStockStatusEx] 
@StockID INT,
@gaming DATETIME
AS
if @StockID is null or not exists (select StockID from CasinoLayout.Stocks where StockID = @StockID)
BEGIN
	RAISERROR('Specify a valid StockID',16,1)
	RETURN (1)
END
declare @StockTypeID int
select @StockTypeID = StockTypeID from CasinoLayout.Stocks where StockID = @StockID
if @gaming is null
BEGIN
--	RAISERROR('Specify a valid Gaming Date',16,1)
--	RETURN (1)
	set @gaming = GeneralPurpose.fn_GetGamingLocalDate2(
				GetUTCDate(),
				--pass current hour difference between local and utc 
				DATEDIFF (hh , GetUTCDate(),GetDate()),
				@StockTypeID)
END

declare @OpenGamingDate datetime
	,@CloseGamingDate datetime
	,@PrevCloseGamingDate datetime
	,@ultimorestime datetime
	,@penultimoRestime datetime
	,@ultimores int
	,@penultimores int
	,@incremento int

select 	@OpenGamingDate = max(GamingDate) 
	from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
	where SS.SnapshotTypeID = 1 
	and SS.StockID = @StockID
	and SS.GamingDate <= @gaming

if @StockTypeID = 1
begin
	declare @OpenLifeCycleID int
	select @OpenLifeCycleID = LifeCycleID from Accounting.tbl_LifeCycles where GamingDate = @OpenGamingDate and StockID = @StockID

	EXECUTE [Accounting].[usp_GetTableLastResult] 
		@OpenLifeCycleID 
		,@ultimorestime  OUTPUT
		,@penultimoRestime  OUTPUT
		,@ultimores  OUTPUT
		,@penultimores  OUTPUT
		,@incremento  OUTPUT

END

select @CloseGamingDate = max(GamingDate) 
	from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
	where SS.SnapshotTypeID = 3 
	and SS.StockID = @StockID
	and SS.GamingDate <= @gaming


select @PrevCloseGamingDate = max(GamingDate) 
	from Accounting.vw_AllLifeCycleNonCancelledSnapshots SS
	where SS.SnapshotTypeID = 3 
	and SS.StockID = @StockID
	and SS.GamingDate < @CloseGamingDate

IF @StockTypeID = 1 --return tables and last result
	SELECT  CasinoLayout.Stocks.Tag,
		APSS.GamingDate 		AS OpenGamingDate,
		CHSS.GamingDate			AS CloseGamingDate,
		LASTCHSS.GamingDate		AS PrevCloseGamingDate,
		CasinoLayout.Stocks.FName,
		CasinoLayout.Stocks.StockTypeID,
		CasinoLayout.Stocks.StockID,
		CHSS.LifeCycleID  		AS CloseLifeCycleID, 
		CHSS.LifeCycleSnapshotID  	AS CloseSnapshotID, 
		CHSS.SnapshotTimeLoc 		AS CloseTime, 
		CHSS.TotalCHF			AS TotCloseCHF,
		CHSS.TotalEUR			AS TotCloseEUR,
		APSS.LifeCycleID  		AS OpenLifeCycleID, 
		APSS.LifeCycleSnapshotID	AS OpenSnapshotID, 
		APSS.SnapshotTimeLoc		AS OpenTime,
		LASTCHSS.LifeCycleID  		AS PrevCloseLifeCycleID, 
		LASTCHSS.LifeCycleSnapshotID  	AS PrevCloseSnapshotID, 
		LASTCHSS.SnapshotTimeLoc	AS PrevCloseTime,
		LASTCHSS.TotalCHF		AS TotPrevCloseCHF,
		LASTCHSS.TotalEUR		AS TotPrevCloseEUR,
		CASE APSS.GamingDate
			WHEN GeneralPurpose.fn_GetGamingLocalDate2(
					GETUTCDATE(),
					--pass current hour difference between local and utc 
					DATEDIFF (hh , GETUTCDATE(),GETDATE()),
					CasinoLayout.Stocks.StockTypeID) THEN 1
		ELSE 0
		END AS IsToday,
		CASE WHEN APSS.GamingDate > CHSS.GamingDate THEN 1
			ELSE 0
		END  AS IsStockOpen
	,@ultimorestime		AS ultimorestime		
	,@ultimores			AS ultimores			
	,@penultimores		AS penultimores		
	,@incremento		AS incremento		



	FROM CasinoLayout.Stocks 
	LEFT OUTER JOIN Accounting.vw_AllSnapshotsEx CHSS 
	ON CHSS.StockID = CasinoLayout.Stocks.StockID 
	AND CHSS.GamingDate = @CloseGamingDate
	AND CHSS.SnapshotTypeID = 3 --Chiusura
	LEFT OUTER JOIN Accounting.vw_AllLifeCycleNonCancelledSnapshots APSS 
	ON APSS.StockID = CasinoLayout.Stocks.StockID 
	AND APSS.GamingDate = @OpenGamingDate
	AND APSS.SnapshotTypeID = 1 --Apertura 
	LEFT OUTER JOIN Accounting.vw_AllSnapshotsEx LASTCHSS 
	ON LASTCHSS.StockID = CasinoLayout.Stocks.StockID 
	AND LASTCHSS.GamingDate = @PrevCloseGamingDate
	AND LASTCHSS.SnapshotTypeID = 3 --Chiusura
	WHERE CasinoLayout.Stocks.StockID = @StockID

ELSE

	SELECT  CasinoLayout.Stocks.Tag,
		APSS.GamingDate 		AS OpenGamingDate,
		CHSS.GamingDate			AS CloseGamingDate,
		LASTCHSS.GamingDate		AS PrevCloseGamingDate,
		CasinoLayout.Stocks.FName,
		CasinoLayout.Stocks.StockTypeID,
		CasinoLayout.Stocks.StockID,
		CHSS.LifeCycleID  		AS CloseLifeCycleID, 
		CHSS.LifeCycleSnapshotID  	AS CloseSnapshotID, 
		CHSS.SnapshotTimeLoc 		AS CloseTime, 
		CHSS.TotalCHF			AS TotCloseCHF,
		CHSS.TotalEUR			AS TotCloseEUR,
		APSS.LifeCycleID  		AS OpenLifeCycleID, 
		APSS.LifeCycleSnapshotID	AS OpenSnapshotID, 
		APSS.SnapshotTimeLoc		AS OpenTime,
		LASTCHSS.LifeCycleID  		AS PrevCloseLifeCycleID, 
		LASTCHSS.LifeCycleSnapshotID  	AS PrevCloseSnapshotID, 
		LASTCHSS.SnapshotTimeLoc	AS PrevCloseTime,
		LASTCHSS.TotalCHF		AS TotPrevCloseCHF,
		LASTCHSS.TotalEUR		AS TotPrevCloseEUR,
		CASE APSS.GamingDate
			WHEN GeneralPurpose.fn_GetGamingLocalDate2(
					GETUTCDATE(),
					--pass current hour difference between local and utc 
					DATEDIFF (hh , GETUTCDATE(),GETDATE()),
					CasinoLayout.Stocks.StockTypeID) THEN 1
		ELSE 0
		END AS IsToday,
		CASE WHEN APSS.GamingDate > CHSS.GamingDate THEN 1
			ELSE 0
		END  AS IsStockOpen
	FROM CasinoLayout.Stocks 
	LEFT OUTER JOIN Accounting.vw_AllSnapshotsEx CHSS 
	ON CHSS.StockID = CasinoLayout.Stocks.StockID 
	AND CHSS.GamingDate = @CloseGamingDate
	AND CHSS.SnapshotTypeID = 3 --Chiusura
	LEFT OUTER JOIN Accounting.vw_AllLifeCycleNonCancelledSnapshots APSS 
	ON APSS.StockID = CasinoLayout.Stocks.StockID 
	AND APSS.GamingDate = @OpenGamingDate
	AND APSS.SnapshotTypeID = 1 --Apertura 
	LEFT OUTER JOIN Accounting.vw_AllSnapshotsEx LASTCHSS 
	ON LASTCHSS.StockID = CasinoLayout.Stocks.StockID 
	AND LASTCHSS.GamingDate = @PrevCloseGamingDate
	AND LASTCHSS.SnapshotTypeID = 3 --Chiusura
	WHERE CasinoLayout.Stocks.StockID = @StockID
GO
