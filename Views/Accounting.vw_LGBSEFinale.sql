SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_LGBSEFinale]
WITH SCHEMABINDING
AS

SELECT 
	lf.GamingDate,
	lf.tag,
	p.Quantity * 1000 AS Finale,
	p.StateTime AS OraChiusura
FROM    Accounting.tbl_Progress p
INNER JOIN 
(
	SELECT 
		LifeCycleID,
		DenoID,
		MAX([StateTime]) AS maxtime
	FROM Accounting.tbl_Progress
	WHERE denoid = 23
	GROUP BY LifeCycleID,DenoID
) ch ON ch.LifecycleId = p.LifecycleId AND ch.maxtime = p.[StateTime] AND p.DenoID = ch.DenoID
INNER JOIN Accounting.vw_AllStockLifeCycles lf ON lf.LifeCycleID = ch.LifeCycleID 






GO
