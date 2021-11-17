SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create	VIEW [Accounting].[vw_DailyConteggioPokerChips]
AS
select
		 GamingDate,
		 DenoID,
		 Denomination,
		 ValueTypeName,
		 ValueTypeID,
		 DenoName,
		 sum(Quantity) as Quantity,
		 1.0 AS ExchangeRate --not interested in exchangerate
		 from  [Accounting].[vw_AllConteggiDenominations]
		 where ValueTypeId in(59)    --gettoni poker
		 --and GamingDate = convert(datetime, '%d.%d.%d', 105)
		 and SnapshotTypeID in (22,23) --avoid counting also conteggi di sorveglianza
		 group by GamingDate,DenoID,
		 Denomination,
		 ValueTypeName,
		 ValueTypeID,
		 DenoName
GO
