SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_CasseLuckyChips]
AS
SELECT [GamingDate]
	  ,StockTypeID
	  ,StockID
	  ,tag
	  ,(ISNULL([InitialQty] - Chiusura,0)) AS UscitaLucky
FROM [Alamo].[Accounting].[vw_AllChiusuraConsegnaDenominations]
WHERE DenoID = 78 AND StockTypeID IN (4,7)

GO
