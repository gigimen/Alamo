SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_GettoniGiocoEuroEliminati]
AS
SELECT 
	DenoName,
	Denomination,
	SUM(Quantity) AS Quantita,
	SUM(QUANTITY *dENOMINATION) AS CHF
  FROM [Alamo].[Accounting].[vw_AllTransactiondenominations]
  WHERE optypeid = 18 AND
	 valuetypeid = 36
	AND CashInbound = 0
GROUP BY DenoID,
	DenoName,
	Denomination
GO
