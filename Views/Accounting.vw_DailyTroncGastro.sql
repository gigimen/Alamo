SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_DailyTroncGastro]
WITH SCHEMABINDING
AS
/*
select * from [Accounting].[vw_DailyTroncSala]
where GamingDate = '5.22.2019'
*/
SELECT a.GamingDate
	,a.TotalRaw
    ,([GeneralPurpose].fn_RoundToClosest(a.TotalRaw,0.01))	AS TotalTronc
	,a.ConteggioTimeLoc
FROM 
(
	SELECT [GamingDate]
		  ,ISNULL(SUM(ValueSfr),0)										AS TotalRaw
		  ,MIN([ConteggioTimeLoc])										AS [ConteggioTimeLoc]
	FROM [Accounting].[vw_AllConteggiDenominations]
	WHERE SnapshotTypeID  = 20 --conteggio tronc gastro
	GROUP BY  [GamingDate]
) a
GO
