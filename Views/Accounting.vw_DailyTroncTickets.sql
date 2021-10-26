SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_DailyTroncTickets]
AS
SELECT 
	GamingDate,
	COUNT(*)									AS TotTickets,
	SUM(CAST(AmountCents AS float)) / 100.0		AS Amount ,
	IsSfr
FROM [Accounting].[vw_AllTicketTransactions]
  WHERE SiteID = 105
  GROUP BY GamingDate,IsSfr
GO
