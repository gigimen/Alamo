SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE	VIEW [Accounting].[vw_DailyConteggioPokerChips]
AS
SELECT
		 GamingDate,
		 DenoID,
		 Denomination,
		 ValueTypeName,
		 ValueTypeID,
		 DenoName,
		 SUM(Quantity) AS Quantity,
		 1.0 AS ExchangeRate --not interested in exchangerate
		 FROM  [Accounting].[vw_AllConteggiDenominations]
		 WHERE ValueTypeId IN(59)    --gettoni poker
		 --and GamingDate = convert(datetime, '%d.%d.%d', 105)
		 AND SnapshotTypeID IN (22,23,10,9) --avoid counting also conteggi di sorveglianza
		 GROUP BY GamingDate,DenoID,
		 Denomination,
		 ValueTypeName,
		 ValueTypeID,
		 DenoName
GO
