SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_GetStockLifeCycleInfo]
(
    @gaming DATETIME,
	@stockTypeID INT
)
RETURNS  @StockStatus TABLE (
	Tag						VARCHAR(16),
	StockTypeID				INT,
	StockID					INT,
	MinBet					INT,
	GamingDate				DATETIME,
	LastGamingDate			DATETIME,
	LastLFID				INT,
	maxLifeCycleSnapshotID	INT,
	StockCompositionID		INT,
	ChiusuraSnapshotID		INT,
	CONTransactionID		INT,
	RipSourceLifeCycleID	INT,
	RipGamingDate			DATETIME,
	RIPTransactionID		INT,
	OraChiusura				DATETIME,
	MyRipTransID			INT,
	MyRipSourceGamingDate	DATETIME,
	MYRipSourceLifeCycleID	INT,
	OraApertura				DATETIME,
	PrevGamingDate			DATETIME,
	PrevLifeCycleID			INT,
	PrevConTransactionID	INT
	)
--WITH SCHEMABINDING
AS
BEGIN
/*

select * from  [Accounting].[fn_GetStockLifeCycleInfo]('12.5.2019',4)


 

DECLARE @gaming DATETIME,
	@stockTypeID INT

SET @gaming = '11.9.2019'
set @stockTypeID = 1
select * from [Accounting].[fn_GetLastLifeCycleByStockType](@gaming,@stockTypeID)

--*/



--go with stock status
INSERT INTO @StockStatus
(
	Tag						,
	StockTypeID				,
	StockID					,
	MinBet					,
	GamingDate				,
	LastGamingDate			,
	LastLFID				,
	maxLifeCycleSnapshotID	,
	StockCompositionID		,
	ChiusuraSnapshotID		,
	CONTransactionID		,
	RipSourceLifeCycleID	,
	RipGamingDate			,
	RIPTransactionID		,
	OraChiusura				,
	MyRipTransID			,
	MyRipSourceGamingDate	,
	MYRipSourceLifeCycleID	,
	OraApertura				,
	PrevGamingDate			,
	PrevLifeCycleID			,
	PrevConTransactionID	
	)
--go with stock status
select
	s.Tag,
	s.StockTypeID,
	s.StockID,
	s.MinBet,
	@gaming as GamingDate,
	lf.GamingDate as LastGamingDate,
	lc.LifeCycleID,
	lc.CloseSnapshotID,
	lf.StockCompositionID,
	r.ChiusuraSnapshotID,
	r.CONTransactionID,
	r.RipSourceLifeCycleID	,--ISNULL(r.RipSourceLifeCycleID	,rip2.SourceLifeCycleID)				AS RipSourceLifeCycleID,
	r.RipGamingDate			,--ISNULL(r.RipGamingDate			,rip2.SourceGamingDate)			AS RipGamingDate		,
	r.RIPTransactionID		,--ISNULL(r.RIPTransactionID		,rip2.TransactionID) AS RIPTransactionID,
	r.ChiusuraTime as OraChiusura,
	RIP.TransactionID as MyRipTransID,
	RIP.SourceGamingDate as MyRipSourceGamingDate,
	RIP.SourceLifeCycleID as MYRipSourceLifeCycleID,
	r.AperturaTime as OraApertura,
	prev.GamingDate as PrevGamingDate,
	prev.LifeCycleID as PrevLifeCycleID,
	CON.TransactionID as PrevConTransactionID
--let start from the active stocks
FROM CasinoLayout.Stocks s 
INNER  join [Accounting].[fn_GetLastLifeCycleByStockType](@gaming,@stockTypeID) lc on lc.StockId = s.StockID 
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = lc.LifeCycleID
inner join [Accounting].[vw_AllChiusuraConsegnaRipristino] r on r.LifeCycleID = lc.LifeCycleID

/*
--this is because we ripristinate the stock fom scratch and not from a previuos chiusura
LEFT OUTER JOIN [Accounting].[vw_AllTransactions] rip2 on rip2.SourceStockTypeID = 2 
AND rip2.SourceGamingDate = @gaming  --ripsitinated today
AND rip2.OpTypeID = 5 --only ripristino
AND rip2.DestStockID = s.StockID
*/

--look for my ripristino the one I have accepted
LEFT OUTER JOIN Accounting.vw_AllTransactions RIP ON RIP.DestLifeCycleID = LF.LifeCycleID and RIP.OpTypeID = 5 --only ripristino operations
--look for consegna that generate the ripristino
LEFT outer  join [Accounting].[fn_GetLastLifeCycleByStockType](@gaming - 1,@stockTypeID) prev on prev.StockId = s.StockID 
LEFT OUTER JOIN Accounting.vw_AllTransactions CON ON CON.SourceLifeCycleID = prev.LifeCycleID and CON.OpTypeID = 6 --only consegna operations
--left outer join Accounting.vw_AllTransactions cons on cons.DestLifeCycleID = r.RipSourceLifeCycleID and cons.SourceStockID = r.StockID and cons.OpTypeID = 6 --consegna
WHERE s.StockTypeID = @stockTypeID
AND @gaming >= s.FromGamingDate 
AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS null) 

--SELECT * FROM @StockStatus


RETURN

END
GO
