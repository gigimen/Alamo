SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [Accounting].[usp_GetAllTableStocksStatus] 
@gaming			datetime,
@today			datetime
AS


declare @stocks table (  
	Tag					varchar(32),
	OpenGamingDate		datetime,
	CloseGamingDate		datetime,
	FName				varchar(32),
	StockTypeID			int,
	StockID				int,
	MinBet				int,
	InitialReserve		int,
	CloseLifeCycleID	int, 
	CloseSnapshotID		int, 
	CloseTimeLoc		datetime, 
	CloseTimeUTC		datetime, 
	OpenLifeCycleID		int, 
	OpenSnapshotID		int, 
	OpenTimeLoc			datetime,
	OpenTimeUTC			datetime,
	IsToday				int,
	IsStockOpen			int,
	ultimorestime		datetime,
	ultimores			int,
	penultimores		int,
	incremento			int
)

declare
@Tag					varchar(32),
@OpenGamingDate		datetime,
@CloseGamingDate		datetime,
@FName				varchar(32),
@StockTypeID			int,
@StockID				int,
@MinBet				int,
@InitialReserve		int,
@CloseLifeCycleID	int, 
@CloseSnapshotID		int, 
@CloseTimeLoc		datetime, 
@CloseTimeUTC		datetime, 
@OpenLifeCycleID		int, 
@OpenSnapshotID		int, 
@OpenTimeLoc			datetime,
@OpenTimeUTC			datetime,
@IsToday				int,
@IsStockOpen			int



declare exclu_cursor cursor FOR

/*

declare @gaming			datetime,
@today			datetime

set @gaming		='2.1.2020'
set @today		= '2.1.2020'


--*/
	SELECT  clo.Tag			as Tag,
		opn.GamingDate		AS OpenGamingDate,
		clo.GamingDate		AS CloseGamingDate,
		clo.FName,
		clo.StockTypeID,
		clo.StockID,
		clo.MinBet,
		clo.InitialReserve,
		clo.LifeCycleID  		AS CloseLifeCycleID, 
		clo.LifeCycleSnapshotID  	AS CloseSnapshotID, 
		clo.SnapshotTimeLoc 		AS CloseTimeLoc, 
		clo.SnapshotTime 		AS CloseTimeUTC, 
		opn.LifeCycleID  		AS OpenLifeCycleID, 
		opn.LifeCycleSnapshotID		AS OpenSnapshotID, 
		opn.SnapshotTimeLoc		AS OpenTimeLoc,
		opn.SnapshotTime		AS OpenTimeUTC,
		case opn.GamingDate
			when @today
			then 1
		else 0
		end as IsToday,
		case when opn.GamingDate > clo.GamingDate then 1
			else 0
		end  as IsStockOpen
	FROM	
	(
	select
		s.Tag,
		s.FName,
		s.StockTypeID,
		s.StockID,
		s.MinBet,
		ISNULL(ris.Totale,0) AS InitialReserve,
		l.GamingDate,
		l.LifeCycleID, 
		ss.LifeCycleSnapshotID, 
		ss.SnapshotTimeLoc , 
		ss.SnapshotTime
	FROM Accounting.tbl_Snapshots ss
		INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
		INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
		inner join 
		(
			select s.StockID,max(ss.LifeCycleID) as LastCloseLFID 
			FROM	Accounting.tbl_Snapshots ss
			INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
			INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
			WHERE   (ss.LCSnapShotCancelID IS NULL) 
			and  ss.SnapshotTypeID = 3 
			and s.StockTypeID = 1 
			and l.GamingDate <= @gaming
			group by s.StockID
		) lc on lc.StockId = s.StockID and l.LifeCycleID = lc.LastCloseLFID
		LEFT OUTER JOIN [CasinoLayout].[vw_AllStockRiservaTotals] ris ON s.StockId = ris.StockID
		where ss.LCSnapShotCancelID IS NULL	
		and  ss.SnapshotTypeID = 3 
		and  @gaming >= s.FromGamingDate 
		AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS null) 
	) clo
	inner join 
	(
	select
		s.FName,
		s.StockTypeID,
		s.StockID,
		s.MinBet,
		l.GamingDate,
		l.LifeCycleID, 
		ss.LifeCycleSnapshotID, 
		ss.SnapshotTimeLoc , 
		ss.SnapshotTime
	from
		Accounting.tbl_Snapshots ss
		INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
		INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
		inner join 
		(
			select s.StockID,max(ss.LifeCycleID) as LastCloseLFID 
			FROM	Accounting.tbl_Snapshots ss
			INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
			INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 
			WHERE   (ss.LCSnapShotCancelID IS NULL) 
			and  ss.SnapshotTypeID = 1 
			and s.StockTypeID = 1 
			and l.GamingDate <= @gaming
			group by s.StockID
		) lc on lc.StockId = s.StockID and l.LifeCycleID = lc.LastCloseLFID
		where ss.LCSnapShotCancelID IS NULL
		and ss.SnapshotTypeID = 1 
		and  @gaming >= s.FromGamingDate 
		AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS null) 
	) opn on opn.StockID = clo.StockID
	order by  clo.StockID

Open exclu_cursor

Fetch Next from exclu_cursor into 
	@Tag				,
	@OpenGamingDate		,
	@CloseGamingDate	,
	@FName				,
	@StockTypeID		,
	@StockID			,
	@MinBet				,
	@InitialReserve		,
	@CloseLifeCycleID	,
	@CloseSnapshotID	,
	@CloseTimeLoc		,
	@CloseTimeUTC		,
	@OpenLifeCycleID	,
	@OpenSnapshotID		,
	@OpenTimeLoc		,
	@OpenTimeUTC		,
	@IsToday			,
	@IsStockOpen		


While @@FETCH_STATUS = 0
Begin
	declare @ultimorestime datetime
		,@penultimoRestime datetime
		,@ultimores int
		,@penultimores int
		,@incremento int

	execute [Accounting].[usp_GetTableLastResult] 
		@OpenLifeCycleID 
		,@ultimorestime  output
		,@penultimoRestime  output
		,@ultimores  output
		,@penultimores  output
		,@incremento  output

	insert into @stocks
	values(
		@Tag				
		,@OpenGamingDate		
		,@CloseGamingDate	
		,@FName				
		,@StockTypeID		
		,@StockID			
		,@MinBet				
		,@InitialReserve		
		,@CloseLifeCycleID	
		,@CloseSnapshotID	
		,@CloseTimeLoc		
		,@CloseTimeUTC		
		,@OpenLifeCycleID	
		,@OpenSnapshotID		
		,@OpenTimeLoc		
		,@OpenTimeUTC		
		,@IsToday			
		,@IsStockOpen		
		,@ultimorestime 
		,@ultimores  
		,@penultimores  
		,@incremento  
		)

	Fetch Next from exclu_cursor into 
		@Tag				,
		@OpenGamingDate		,
		@CloseGamingDate	,
		@FName				,
		@StockTypeID		,
		@StockID			,
		@MinBet				,
		@InitialReserve		,
		@CloseLifeCycleID	,
		@CloseSnapshotID	,
		@CloseTimeLoc		,
		@CloseTimeUTC		,
		@OpenLifeCycleID	,
		@OpenSnapshotID		,
		@OpenTimeLoc		,
		@OpenTimeUTC		,
		@IsToday			,
		@IsStockOpen		
End


close exclu_cursor
deallocate exclu_cursor

select 
	Tag					,
	OpenGamingDate		,
	CloseGamingDate		,
	FName				,
	StockTypeID			,
	StockID				,
	MinBet				,
	InitialReserve		,
	CloseLifeCycleID	,
	CloseSnapshotID		,
	CloseTimeLoc		,
	CloseTimeUTC		,
	OpenLifeCycleID		,
	OpenSnapshotID		,
	OpenTimeLoc			,
	OpenTimeUTC			,
	IsToday				,
	IsStockOpen			,
	ultimorestime		,
	ultimores			,
	penultimores		,
	incremento			
from @stocks


return 0
GO
