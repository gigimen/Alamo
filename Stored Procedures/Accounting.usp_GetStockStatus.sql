SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Accounting].[usp_GetStockStatus] 
@StockID int,
@gaming datetime
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

	execute [Accounting].[usp_GetTableLastResult] 
		@OpenLifeCycleID 
		,@ultimorestime  output
		,@penultimoRestime  output
		,@ultimores  output
		,@penultimores  output
		,@incremento  output

end

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

if @StockTypeID = 1 --return tables and last result
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
		APSS.LifeCycleID  		AS OpenLifeCycleID, 
		APSS.LifeCycleSnapshotID	AS OpenSnapshotID, 
		APSS.SnapshotTimeLoc		AS OpenTime,
		LASTCHSS.LifeCycleID  		AS PrevCloseLifeCycleID, 
		LASTCHSS.LifeCycleSnapshotID  	AS PrevCloseSnapshotID, 
		LASTCHSS.SnapshotTimeLoc	AS PrevCloseTime,
		LASTCHSS.TotalCHF		AS TotPrevCloseCHF,
		case APSS.GamingDate
			when GeneralPurpose.fn_GetGamingLocalDate2(
					GetUTCDate(),
					--pass current hour difference between local and utc 
					DATEDIFF (hh , GetUTCDate(),GetDate()),
					CasinoLayout.Stocks.StockTypeID) then 1
		else 0
		end as IsToday,
		case when APSS.GamingDate > CHSS.GamingDate then 1
			else 0
		end  as IsStockOpen
	,@ultimorestime		as ultimorestime		
	,@ultimores			as ultimores			
	,@penultimores		as penultimores		
	,@incremento		as incremento		



	from CasinoLayout.Stocks 
	LEFT OUTER JOIN Accounting.vw_AllSnapshots CHSS 
	ON CHSS.StockID = CasinoLayout.Stocks.StockID 
	AND CHSS.GamingDate = @CloseGamingDate
	AND CHSS.SnapshotTypeID = 3 --Chiusura
	LEFT OUTER JOIN Accounting.vw_AllLifeCycleNonCancelledSnapshots APSS 
	ON APSS.StockID = CasinoLayout.Stocks.StockID 
	AND APSS.GamingDate = @OpenGamingDate
	AND APSS.SnapshotTypeID = 1 --Apertura 
	LEFT OUTER JOIN Accounting.vw_AllSnapshots LASTCHSS 
	ON LASTCHSS.StockID = CasinoLayout.Stocks.StockID 
	AND LASTCHSS.GamingDate = @PrevCloseGamingDate
	AND LASTCHSS.SnapshotTypeID = 3 --Chiusura
	where CasinoLayout.Stocks.StockID = @StockID

else

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
		APSS.LifeCycleID  		AS OpenLifeCycleID, 
		APSS.LifeCycleSnapshotID	AS OpenSnapshotID, 
		APSS.SnapshotTimeLoc		AS OpenTime,
		LASTCHSS.LifeCycleID  		AS PrevCloseLifeCycleID, 
		LASTCHSS.LifeCycleSnapshotID  	AS PrevCloseSnapshotID, 
		LASTCHSS.SnapshotTimeLoc	AS PrevCloseTime,
		LASTCHSS.TotalCHF		AS TotPrevCloseCHF,
		case APSS.GamingDate
			when GeneralPurpose.fn_GetGamingLocalDate2(
					GetUTCDate(),
					--pass current hour difference between local and utc 
					DATEDIFF (hh , GetUTCDate(),GetDate()),
					CasinoLayout.Stocks.StockTypeID) then 1
		else 0
		end as IsToday,
		case when APSS.GamingDate > CHSS.GamingDate then 1
			else 0
		end  as IsStockOpen
	from CasinoLayout.Stocks 
	LEFT OUTER JOIN Accounting.vw_AllSnapshots CHSS 
	ON CHSS.StockID = CasinoLayout.Stocks.StockID 
	AND CHSS.GamingDate = @CloseGamingDate
	AND CHSS.SnapshotTypeID = 3 --Chiusura
	LEFT OUTER JOIN Accounting.vw_AllLifeCycleNonCancelledSnapshots APSS 
	ON APSS.StockID = CasinoLayout.Stocks.StockID 
	AND APSS.GamingDate = @OpenGamingDate
	AND APSS.SnapshotTypeID = 1 --Apertura 
	LEFT OUTER JOIN Accounting.vw_AllSnapshots LASTCHSS 
	ON LASTCHSS.StockID = CasinoLayout.Stocks.StockID 
	AND LASTCHSS.GamingDate = @PrevCloseGamingDate
	AND LASTCHSS.SnapshotTypeID = 3 --Chiusura
	where CasinoLayout.Stocks.StockID = @StockID
GO
GRANT EXECUTE ON  [Accounting].[usp_GetStockStatus] TO [SolaLetturaNoDanni]
GO
