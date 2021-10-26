SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_SlotpotDailyChiusure]
AS

SELECT [SourceGamingDate]				AS GamingDate
		,SUM(Quantity)					AS JPAtCageCents
		,SUM(Quantity*Denomination)		AS JPAtCages
FROM [Accounting].[vw_AllTransactionDenominations]
WHERE OpTypeID = 6 --only Consegna
AND DenoID = 100 --only slotpot
GROUP BY [SourceGamingDate]
GO
