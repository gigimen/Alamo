SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE FUNCTION [Accounting].[fn_GetLastLifeCycleByStockType]
(
    @gaming DATETIME,
	@stockTypeID INT
)
RETURNS  @ret TABLE (
	LifeCycleID				INT PRIMARY KEY,
	GamingDate				DATETIME,
	StockID					INT,
	Tag						VARCHAR(16),
	StockTypeID				INT,
	MinBet					INT,
	CloseSnapshotID			INT,
	CloseTimeUTC			datetime
	)
--WITH SCHEMABINDING
AS
BEGIN



IF @stockTypeID IS NULL
BEGIN
	INSERT INTO @ret
	(
		LifeCycleID,
		GamingDate,
		StockID,
		Tag,
		StockTypeID,
		MinBet,
		CloseSnapshotID,
		CloseTimeUTC
	)
	/*

	select * from  [Accounting].[fn_GetLastStockLifeCycle]('6.23.2019',null)



	--*/


	/*

	DECLARE @gaming DATETIME,
		@stockTypeID INT

	SET @gaming = '6.28.2020'
	set @stockTypeID = 1

	--*/
		SELECT 
			l.LifeCycleID,
			l.GamingDate,
			ms.StockID,
			ms.Tag,
			ms.StockTypeID,
			ms.MinBet,
			ss.LifeCycleSnapshotID	,
			ss.SnapshotTime
		FROM
		(
			SELECT 
				MAX(l.GamingDate) AS maxgamingdate,
				l.StockID,
				s.StockTypeID,
				s.Tag,
				s.MinBet
			FROM Accounting.tbl_Snapshots ss
			INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
			INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 	
			--esiste un'apertura non cancellata
			WHERE   ss.LCSnapShotCancelID IS NULL AND  ss.SnapshotTypeID = 1 --APERTURA
			AND l.GamingDate <= @gaming 
			GROUP BY l.StockID,
				s.StockTypeID,
				s.Tag,
				s.MinBet
		) ms
		INNER JOIN Accounting.tbl_LifeCycles l ON ms.maxgamingdate = l.GamingDate  AND ms.StockID = l.StockID
		--con una apertura non cancellata
		inner join Accounting.tbl_Snapshots sa ON sa.LifeCycleID = l.LifeCycleID AND sa.LCSnapShotCancelID IS NULL AND  sa.SnapshotTypeID = 1
		LEFT OUTER JOIN Accounting.tbl_Snapshots ss ON ss.LifeCycleID = l.LifeCycleID AND  ss.SnapshotTypeID = 3 and ss.LCSnapShotCancelID is null --chiusura
END
ELSE
BEGIN
	INSERT INTO @ret
	(
		LifeCycleID,
		GamingDate,
		StockID,
		Tag,
		StockTypeID,
		MinBet,
		CloseSnapshotID,
		CloseTimeUTC
	)
	/*

	select * from  [Accounting].[fn_GetLastStockLifeCycle]('6.23.2019',1)



	--*/


	/*

	DECLARE @gaming DATETIME,
		@stockTypeID INT

	SET @gaming = '4.10.2020'
	set @stockTypeID = 6

	--*/
		SELECT 
			l.LifeCycleID,
			l.GamingDate,
			ms.StockID,
			ms.Tag,
			ms.StockTypeID,
			ms.MinBet,
			ss.LifeCycleSnapshotID	,
			ss.SnapshotTime
		FROM
		(
			SELECT 
				MAX(l.GamingDate) AS maxgamingdate,
				l.StockID,
				s.StockTypeID,
				s.Tag,
				s.MinBet
			FROM Accounting.tbl_Snapshots ss
			INNER JOIN Accounting.tbl_LifeCycles l ON ss.LifeCycleID = l.LifeCycleID 
			INNER JOIN CasinoLayout.Stocks s ON s.StockID = l.StockID 	
			--esiste un'apertura non cancellata
			WHERE   ss.LCSnapShotCancelID IS NULL AND  ss.SnapshotTypeID = 1 --APERTURA
			AND l.GamingDate <= @gaming AND s.StockTypeID = @stockTypeID
			GROUP BY l.StockID,
				s.StockTypeID,
				s.Tag,
				s.MinBet
		) ms
		INNER JOIN Accounting.tbl_LifeCycles l ON ms.maxgamingdate = l.GamingDate  AND ms.StockID = l.StockID
		--con una apertura non cancellata
		inner join Accounting.tbl_Snapshots sa ON sa.LifeCycleID = l.LifeCycleID AND sa.LCSnapShotCancelID IS NULL AND  sa.SnapshotTypeID = 1
		LEFT OUTER JOIN Accounting.tbl_Snapshots ss ON ss.LifeCycleID = l.LifeCycleID AND  ss.SnapshotTypeID = 3  and ss.LCSnapShotCancelID is null --chiusura

END

RETURN

END
GO
