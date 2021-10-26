SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE VIEW [Accounting].[vw_GastroDailyConteggio]
AS
	SELECT 
		GamingDate,
		StockID,
		Tag,
		SUM(Quantity*Denomination*ExchangeRate) AS Totale
	FROM Accounting.vw_AllConteggiDenominations
	WHERE SnapshotTypeID = 10
	GROUP BY GamingDate,
		StockID,
		Tag
GO
