SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Accounting].[vw_ConfrontoDropTavoli]
AS
SELECT 
		D.[StockID]
      ,D.[Tag]
      ,D.[GamingDate]
      ,D.DropStimato
	,C.DropContato 
	,CAST(/*ABS*/(C.[DropContato] - D.[DropStimato]) AS FLOAT)/ CAST(C.[DropContato] AS FLOAT) * 100 AS Perc
	,ISNULL(T.TagliPiccoli,0) AS TagliPiccoli
FROM
( 
	SELECT [StockID]
      ,[GamingDate]
      ,[Tag]
      ,[Quantity] * Denomination AS DropStimato
  FROM [Accounting].[vw_AllSnapshotDenominations]
  WHERE StockTypeID = 1 AND denoid = 13 AND SnapshotTypeID = 3
  ) D
   INNER JOIN 
 (
  SELECT stockID,GamingDate 
--        ,SUM([Quantity] * Denomination*ExchangeRate) AS DropContato
        ,SUM([Quantity] * Denomination) AS DropContato

  FROM [Accounting].[vw_AllConteggiDenominations]
  WHERE SnapshotTypeID = 7 --AND StockTypeID = 1 
GROUP BY stockID,GamingDate  
) C ON C.GamingDate = D.GamingDate AND C.StockID = D.StockID
LEFT OUTER JOIN
(
  SELECT stockID,GamingDate 
        ,COUNT(*) AS TagliPiccoli

  FROM [Accounting].[vw_AllConteggiDenominations]
  WHERE SnapshotTypeID = 7 AND denomination IN(5,10,20,50)
  GROUP BY stockID,GamingDate  
) T ON T.GamingDate = D.GamingDate AND T.StockID = D.StockID



GO
