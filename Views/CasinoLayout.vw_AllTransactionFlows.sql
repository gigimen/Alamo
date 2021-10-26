SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [CasinoLayout].[vw_AllTransactionFlows]
WITH SCHEMABINDING
AS
SELECT 	CasinoLayout.OperationTypes.FName as OperationName, 
	da.FDescription as 'From',
	a.FDescription as 'To'
FROM   CasinoLayout.OperationTypes 
	INNER JOIN CasinoLayout.TransactionFlows ON CasinoLayout.OperationTypes.OpTypeID = CasinoLayout.TransactionFlows.OpTypeID 
	INNER JOIN CasinoLayout.StockTypes a ON a.StockTypeID = CasinoLayout.TransactionFlows.DestStockTypeID 
	INNER JOIN CasinoLayout.StockTypes da ON da.StockTypeID = CasinoLayout.TransactionFlows.SourceStockTypeID  








GO
