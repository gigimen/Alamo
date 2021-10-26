SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [Accounting].[usp_GetLastReserveOfGamingDate] 
@GamingDate DATETIME
AS
/*
DECLARE @GamingDate datetime

SET @GamingDate = '9.24.2014'
*/
IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE name LIKE '#TmpRiservaTavoli%')
BEGIN
	PRINT 'dropping #TmpRiservaTavoli'
	DROP TABLE #TmpRiservaTavoli
END

IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE name LIKE '#TmpPrevRiservaTavoli%')
BEGIN
	PRINT 'dropping #TmpPrevRiservaTavoli'
	DROP TABLE #TmpPrevRiservaTavoli
END


SELECT 
	l.LifeCycleID,
	MAX(p.StateTime) AS MRTime
INTO #TmpRiservaTavoli
FROM Accounting.tbl_Progress p
	INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
	INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND p.DenoID = sd.DenoID
	INNER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = sd.DenoID
WHERE l.GamingDate = @GamingDate
	AND sd.IsRiserva = 1 --reserve
GROUP BY l.LifeCycleID



--SELECT * FROM #TmpRiservaTavoli

SELECT 
	m.LifeCycleID,
	MAX(p.StateTime) AS PrevTime
INTO #TmpPrevRiservaTavoli
FROM #TmpRiservaTavoli m 
	LEFT OUTER JOIN Accounting.tbl_Progress p ON p.LifeCycleID = m.LifeCycleID   
	LEFT OUTER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND p.DenoID = sd.DenoID
	LEFT OUTER JOIN CasinoLayout.tbl_Denominations den ON den.DenoID = sd.DenoID
WHERE p.StateTime < m.MRTime AND sd.IsRiserva = 1 --reserve
GROUP BY m.LifeCycleID,
	m.MRTime

--SELECT * FROM #TmpPrevRiservaTavoli

SELECT 
	p.LifeCycleID,
	p.DenoID,
	p.Quantity,
	GeneralPurpose.fn_UTCToLocal(1,m.MRTime) AS StateTime,
	m.Total,
	GeneralPurpose.fn_UTCToLocal(1,pr.PrevTime) AS PrevTime,
	pr.Total AS PrevTotal,
	CASE
		WHEN pr.PrevTime IS NULL THEN 'Ap' 
		WHEN pr.Total > m.Total THEN 'Pre' 
		ELSE 'Ver'
	END AS Operazione			
FROM    Accounting.tbl_Progress p
INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = p.DenoID
INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND sd.DenoID = d.DenoID
INNER JOIN 
(
	SELECT m.LifeCycleID,
			m.MRTime,
			sum(p.Quantity* d.Denomination) AS Total
	FROM #TmpRiservaTavoli m
	INNER JOIN Accounting.tbl_Progress p ON p.LifeCycleID = m.LifeCycleID AND p.StateTime = m.MRTime
	INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
	INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = p.DenoID
	INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND sd.DenoID = d.DenoID
	WHERE sd.IsRiserva = 1 --reserve
	GROUP BY  m.LifeCycleID,
			m.MRTime
) 
m ON m.LifeCycleID = p.LifeCycleID AND p.StateTime = m.MRTime
LEFT OUTER JOIN 
(	SELECT m.LifeCycleID,
			m.PrevTime,
			sum(p.Quantity* d.Denomination) AS Total
	FROM #TmpPrevRiservaTavoli m
	INNER JOIN Accounting.tbl_Progress p ON p.LifeCycleID = m.LifeCycleID AND p.StateTime = m.PrevTime
	INNER JOIN Accounting.tbl_LifeCycles l ON l.LifeCycleID = p.LifeCycleID
	INNER JOIN CasinoLayout.tbl_Denominations d ON d.DenoID = p.DenoID
	INNER JOIN CasinoLayout.StockComposition_Denominations sd ON sd.StockCompositionID = l.StockCompositionID AND sd.DenoID = d.DenoID
	WHERE sd.IsRiserva = 1 --reserve
	GROUP BY  m.LifeCycleID,
			m.PrevTime
) pr ON l.LifeCycleID = pr.LifeCycleID 
ORDER BY m.MRTime


IF EXISTS (SELECT name FROM tempdb..sysobjects 
	WHERE name LIKE '#TmpRiservaTavoli%'
	)
begin
	print 'dropping #TmpRiservaTavoli'
	drop table #TmpRiservaTavoli
end


IF EXISTS (SELECT name FROM tempdb..sysobjects WHERE name LIKE '#TmpPrevRiservaTavoli%')
begin
	print 'dropping #TmpPrevRiservaTavoli'
	drop table #TmpPrevRiservaTavoli
END
GO
