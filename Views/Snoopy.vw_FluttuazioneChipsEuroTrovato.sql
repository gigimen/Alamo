SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  VIEW [Snoopy].[vw_FluttuazioneChipsEuroTrovato]
WITH SCHEMABINDING
AS
SELECT 
	lf.GamingDate,
	lf.LifeCycleID,
	ISNULL(t.TotTrovato,0) AS ChipsEuroTrovati,
	ISNULL(r.totrestituito,0) AS ChipsEuroRestituiti,
	ISNULL(t.TotTrovato,0) - ISNULL(r.totrestituito,0) AS Bilancio
	FROM Accounting.vw_AllStockLifeCycles lf
	FULL OUTER JOIN
(
SELECT SUM([Rap_ImportoCHF]) AS totrestituito
      ,[Rap_Datarestituzione] AS GamingDate
  FROM Snoopy.tbl_DenaroTrovato
  WHERE Rap_Datarestituzione IS NOT NULL AND Rap_Datarestituzione >= '1.1.2012'
  AND [Rap_ChipsEuro] = 1
  GROUP BY Rap_Datarestituzione
) r ON r.GamingDate = lf.GamingDate
FULL OUTER JOIN 
(
SELECT SUM([Rap_ImportoCHF]) AS TotTrovato
      ,Rap_GamingDate  AS GamingDate
  FROM Snoopy.tbl_DenaroTrovato
  WHERE Rap_GamingDate IS NOT NULL AND Rap_GamingDate >= '1.1.2012'
  AND [Rap_ChipsEuro] = 1
  GROUP BY Rap_GamingDate
) t ON lf.GamingDate = t.GamingDate
WHERE lf.StockID = 46 --look only at CAssa centrale lifecycles
GO
