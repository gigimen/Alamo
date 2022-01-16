SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [deprecated].[vw_ConteggioGettoni]
AS

/*

select * from ForIncasso.vw_ConteggioGettoni where GamingDate  = '7.5.2019' 
*/
SELECT GamingDate,[CurrencyAcronim]
      ,SUM([Quantity] * Denomination) TotContato
FROM [Accounting].[vw_AllConteggiDenominations]
WHERE ValueTypeID IN (1,36,42) AND SnapshotTypeID NOT IN (14,15)
--AND GamingDate = '7.5.2019' 
GROUP BY GamingDate,CurrencyAcronim
GO
