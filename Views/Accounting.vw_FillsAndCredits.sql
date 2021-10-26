SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_FillsAndCredits]
AS
	SELECT t.SourceLifeCycleID AS LifeCycleID,--@pend = --ISNULL(COUNT(transactionID),0) ,
		SUM(CASE WHEN t.OpTypeID = 1 THEN 1 ELSE 0 END) AS FillsCount,
		SUM(CASE WHEN t.OpTypeID = 4 THEN 1 ELSE 0 END) AS CreditsCount,
		SUM(CASE WHEN t.OpTypeID = 1 THEN [TotalEURForSource] ELSE 0 END) AS FillsTotEUR,
		SUM(CASE WHEN t.OpTypeID = 4 THEN [TotalEURForSource] ELSE 0 END) AS CreditsTotEUR,
		SUM(CASE WHEN t.OpTypeID = 1 THEN [TotalCHFForSource] ELSE 0 END) AS FillsTotCHF,
		SUM(CASE WHEN t.OpTypeID = 4 THEN [TotalCHFForSource] ELSE 0 END) AS CreditsTotCHF
	FROM Accounting.vw_AllTransactionsEx t 
	GROUP BY t.SourceLifeCycleID
GO
