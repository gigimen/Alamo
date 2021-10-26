SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_BSELiveGameEstimatedResults]
WITH SCHEMABINDING
AS
SELECT 
	lf.LifeCycleID,
	lf.StockID,
	lf.GamingDate,
	(CAST(p.Quantity AS FLOAT))* 1000.0 AS BSE
FROM Accounting.tbl_Progress p
INNER JOIN 
(
	SELECT LifeCycleID
		  ,MAX([StateTime]) AS maxtime
	FROM Accounting.tbl_Progress
	WHERE denoid = 23
	GROUP BY LifeCycleID
) ch ON ch.LifecycleId = p.LifecycleId AND ch.maxtime = p.[StateTime] AND p.denoid = 23
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = ch.LifeCycleID 








GO
