SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_PokerCreditFills]
AS
	SELECT 
		t.SourceLifeCycleID	AS LifeCycleID,
		t.SourceTag			AS Tag,
		t.SourceGamingDate	AS GamingDate,
		SUM(CASE WHEN t.OpTypeID = 1 THEN 1 ELSE 0 END) AS Fills,
		SUM(CASE WHEN t.OpTypeID = 4 THEN 1 ELSE 0 END) AS Credits,
		SUM(CASE WHEN t.OpTypeID = 1 THEN 1 ELSE 0 END) -
		SUM(CASE WHEN t.OpTypeID = 4 THEN 1 ELSE 0 END) AS Pending

	FROM [Accounting].[vw_AllTransactionsEx] t 
	WHERE t.SourceStockTypeID = 23 AND t.OpTypeID IN(4,1)
	GROUP BY t.SourceLifeCycleID,
		t.SourceTag,
		t.SourceGamingDate
GO
