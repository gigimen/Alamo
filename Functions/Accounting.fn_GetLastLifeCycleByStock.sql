SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE FUNCTION [Accounting].[fn_GetLastLifeCycleByStock]
(
    @gaming DATETIME,
	@stockID INT
)
RETURNS  @ret TABLE (
	LifeCycleID				INT PRIMARY KEY,
	GamingDate				DATETIME,
	StockID					INT,
	Tag						VARCHAR(16),
	StockTypeID				INT,
	MinBet					INT,
	CloseSnapshotID			INT,
	CloseTimeUTC			DATETIME
	)
--WITH SCHEMABINDING
AS
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

select * from  [Accounting].[fn_GetLastLifeCycleByStock]('6.23.2020',17)



--*/


/*

DECLARE @gaming DATETIME,
@stockID INT

SET @gaming = '4.10.2020'
set @stockID = 36

--*/
SELECT 
	l.LifeCycleID,
	l.GamingDate,
	@stockID AS StockID,
	ms.Tag,
	ms.StockTypeID,
	ms.MinBet,
	ss.LifeCycleSnapshotID	,
	ss.SnapshotTime
FROM
(

/*

DECLARE @gaming DATETIME,
@stockID INT

SET @gaming = '4.10.2020'
set @stockID = 37

--*/	

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
	AND l.GamingDate <= @gaming AND l.StockID = @stockID
	GROUP BY l.StockID,
		s.StockTypeID,
		s.Tag,
		s.MinBet
) ms
INNER JOIN Accounting.tbl_LifeCycles l ON ms.maxgamingdate = l.GamingDate  AND ms.StockID = l.StockID
LEFT OUTER JOIN Accounting.tbl_Snapshots ss ON ss.LifeCycleID = l.LifeCycleID AND  ss.SnapshotTypeID = 3 --chiusura

RETURN

END
GO
