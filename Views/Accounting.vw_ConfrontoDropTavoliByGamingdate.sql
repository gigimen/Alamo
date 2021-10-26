SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [Accounting].[vw_ConfrontoDropTavoliByGamingdate]
AS
SELECT D.[GamingDate]
      ,D.DropStimato
	,C.DropContato 
	,CAST(ABS(C.[DropContato] - D.[DropStimato]) AS FLOAT)/ CAST(C.[DropContato] AS FLOAT) * 100 AS Perc
FROM
( 
	SELECT [GamingDate]
      ,SUM([Quantity] * Denomination) AS DropStimato
  FROM [Accounting].[vw_AllSnapshotDenominations]
  WHERE StockTypeID = 1 AND denoid = 13 AND SnapshotTypeID = 3
  GROUP BY [GamingDate]
  ) D
   INNER JOIN 
 (
  SELECT GamingDate 
        ,SUM([Quantity] * Denomination*ExchangeRate) AS DropContato

  FROM [Accounting].[vw_AllConteggiDenominations]
  WHERE SnapshotTypeID = 7 --AND StockTypeID = 1 
GROUP BY GamingDate  
) C ON C.GamingDate = D.GamingDate 

GO
