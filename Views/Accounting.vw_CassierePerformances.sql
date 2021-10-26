SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_CassierePerformances]
WITH SCHEMABINDING
AS
SELECT  TOP 100 PERCENT 
	OwnerName, 
	GamingMonth,
	GamingYear,
	COUNT(*) AS QuanteVolte, 
	STR(SUM(ABS(DiffCassa)),10,2) AS TotDiffCassaAssoluta, 
	STR(AVG(ABS(DiffCassa)),10,2) AS MediaAssoluta,
	STR(SUM(DiffCassa),10,2) AS TotDiffCassa, 
	STR(AVG(DiffCassa),10,2) AS Media,
	SUM(case  when DiffCassa = 0 then 1 else 0 end) AS TurniBuoni
FROM    Accounting.vw_AllStockDiffCassa
GROUP BY OwnerName,GamingMonth,GamingYear
ORDER BY GamingMonth,MediaAssoluta,QuanteVolte desc
GO
