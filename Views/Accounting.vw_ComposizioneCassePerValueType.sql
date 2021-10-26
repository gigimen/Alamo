SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_ComposizioneCassePerValueType]
AS
/*

select * from [Accounting].[vw_ComposizioneCassePerValueType]
where GamingDate = '1.1.2019'

*/
SELECT [StockID]
      ,[Tag]
      ,[ValueTypeID]
      ,[ValueTypeName]
	  ,GamingDate
      ,SUM([Denomination] * [InitialQty]) AS InitialAmount
	  ,SUM([Denomination] * [Ripristinato]) AS Apertura
  FROM [Accounting].[vw_AllChiusuraConsegnaDenominations]
  WHERE ValueTypeID IN (1,2,3,7)
  AND StockTypeID IN (4,7)
  GROUP BY [StockID]
      ,[Tag]
      ,[ValueTypeID]
      ,[ValueTypeName]
	  ,GamingDate
GO
