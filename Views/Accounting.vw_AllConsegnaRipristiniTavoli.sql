SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_AllConsegnaRipristiniTavoli]
WITH SCHEMABINDING
AS
SELECT TOP 100 PERCENT 
	LF.Tag,
	LF.StockTypeID,
	st.FDescription AS StockTypeName,
	LF.StockID,
	LF.LifeCycleID,
	LF.GamingDate,
	ISNULL(CON.Consegna,0) AS Consegna,
	ISNULL(RIP.Ripristino,0) AS Ripristino
FROM Accounting.vw_AllStockLifeCycles LF
INNER JOIN CasinoLayout.StockTypes st ON st.StockTypeID = LF.StockTypeID
LEFT OUTER JOIN 
(
	SELECT 
		SourceLifeCycleID,
		TotalForSource AS Consegna 
	FROM Accounting.vw_AllTransactions 
		WHERE OpTypeID = 6 --only Consegna operations
		-- transaction is pending if DestLifeCycleID is null
		--and  DestLifeCycleID is null
		AND 
		(
		   --all Stocks that this stock can be a receiver of their transactions
		   SourceStockTypeID IN 
		   ( 
			SELECT SourceStockTypeID FROM CasinoLayout.TransactionFlows WHERE 
				DestStockTypeID = 2 --to main stock
				AND OpTypeID = 6 --Consegna
		   )
		OR --all Stocks that this stock is the receiver of their transactions
			DestStockID = 31 --main stock
		OR --all Stocks that this stocktype is the receiver of their transactions
			DestStockTypeID = 2 --main stock stock type
		)
		AND sourceStockTypeID in (1,3) --source stock of type tavoli,SMT

) CON ON LF.LifeCycleID = CON.SourceLifeCycleID
LEFT OUTER JOIN 
(
SELECT 
	SourceGamingDate,
	TotalForSource AS Ripristino,
	DestStockID 
FROM Accounting.vw_AllTransactions 
	WHERE OpTypeID = 5 --only ripristino operations
	-- transaction is pending if DestLifeCycleID is null
	AND DestStockTypeID in (1,3) --dest stock of type tavoli,SMT
	AND SourceStockID = 31 --main stock
) RIP ON LF.StockID = RIP.DestStockID AND LF.GamingDate = RIP.SourceGamingDate
WHERE LF.StockTypeID IN(1,3) --tavoli e SMT
ORDER BY LF.StockID
GO
