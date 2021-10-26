SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_LGResultIncr]
WITH SCHEMABINDING
AS
SELECT s.stockid
		,s.tag
		,lf.LifeCycleID
	  ,lf.gamingdate
      ,p.[DenoID]
      ,p.StateTime
      ,prec.StateTime AS PrecTime
      ,p.[Quantity] * 1000 AS Result
      ,ISNULL(prec.Quantity,0) * 1000 AS PrecResult
      ,(p.Quantity - ISNULL(prec.quantity,0) ) * 1000 AS IncrResult
FROM Accounting.tbl_Progress p
INNER JOIN Accounting.tbl_LifeCycles lf ON lf.LifeCycleID = p.LifeCycleID  
INNER JOIN CasinoLayout.Stocks s ON s.StockID = lf.StockID
LEFT OUTER JOIN 
(
	SELECT 
		LifeCycleID,
		Quantity,
		DenoID,
		StateTime
	FROM Accounting.tbl_Progress 
) prec ON prec.LifeCycleID = p.LifeCycleID AND prec.DenoID = p.DenoID AND prec.StateTime = DATEADD(hh,-1,p.StateTime)
WHERE p.DenoID = 23 AND s.StockTypeID = 1

 














GO
