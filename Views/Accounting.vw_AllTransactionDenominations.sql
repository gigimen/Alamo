SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Accounting].[vw_AllTransactionDenominations]
WITH SCHEMABINDING
AS
SELECT  SourceStock.Tag 			AS SourceTag, 
	SourceStock.StockID 			AS SourceStockID, 
	SourceStock.StockTypeID 		AS SourceStockTypeID, 
	Accounting.tbl_Transactions.SourceLifeCycleID,
	SourceLFID.GamingDate			AS SourceGamingDate, 
	Accounting.tbl_Transactions.SourceTime		AS SourceTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,Accounting.tbl_Transactions.SourceTime) as SourceTimeLoc, 
	DestStock.Tag				AS DestStockTag,
	DestLFID.GamingDate			AS DestGamingDate,
	Accounting.tbl_Transactions.DestStockID,
	Accounting.tbl_Transactions.DestStockTypeID,
	Accounting.tbl_Transactions.DestLifeCycleID,
	Accounting.tbl_Transactions.DestUserAccessID,
	DUAID.UserID				as DestUserID,
	DUAID.UserGroupID			as DestUserGroupID,
	CasinoLayout.OperationTypes.OpTypeID, 
	CasinoLayout.OperationTypes.FName		AS OperationName, 
	Accounting.tbl_Transactions.TransactionID, 
	Accounting.tbl_Transactions.SourceUserAccessID,
	SUAID.UserID				as SourceUserID,
	SUAID.UserGroupID			as SourceUserGroupID,
	Accounting.tbl_Transactions.TRCancelID, 
	Accounting.tbl_Transactions.DestTime		as DestTimeUTC,
	GeneralPurpose.fn_UTCToLocal(1,Accounting.tbl_Transactions.DestTime) as DestTimeLoc,
	Accounting.tbl_TransactionValues.Quantity, 
	Accounting.tbl_TransactionValues.ExchangeRate, 
	Accounting.tbl_TransactionValues.CashInbound,
	vt.FName			As ValueTypeName,
	cu.CurrencyID,
	cu.IsoName			AS CurrencyAcronim,
	den.FName			As DenoName,
	den.FDescription,	
	den.IsFisical, 
	den.Denomination,
	den.DenoID,
	den.ValueTypeID,
	SDENO.WeightInTotal			AS WeightForSource,
	DDENO.WeightInTotal			AS WeightForDest 
	FROM    Accounting.tbl_Transactions 
 	INNER JOIN FloorActivity.tbl_UserAccesses 		SUAID 		ON SUAID.UserAccessID = Accounting.tbl_Transactions.SourceUserAccessID 
	INNER JOIN CasinoLayout.OperationTypes 				ON CasinoLayout.OperationTypes.OpTypeID = Accounting.tbl_Transactions.OpTypeID 
        INNER JOIN Accounting.tbl_LifeCycles 		SourceLFID	ON SourceLFID.LifeCycleID = Accounting.tbl_Transactions.SourceLifeCycleID 
        INNER JOIN CasinoLayout.Stocks 			SourceStock 	ON SourceStock.StockID = SourceLFID.StockID
        LEFT OUTER JOIN Accounting.tbl_LifeCycles 		DestLFID 	ON Accounting.tbl_Transactions.DestLifeCycleID = DestLFID.LifeCycleID
        LEFT OUTER JOIN CasinoLayout.Stocks 		DestStock 	ON Accounting.tbl_Transactions.DestStockID = DestStock.StockID
        LEFT OUTER JOIN Accounting.tbl_TransactionValues 			ON Accounting.tbl_TransactionValues.TransactionID = Accounting.tbl_Transactions.TransactionID
        LEFT OUTER JOIN CasinoLayout.tbl_Denominations den 			ON den.DenoID = Accounting.tbl_TransactionValues.DenoID 
	LEFT OUTER JOIN CasinoLayout.tbl_ValueTypes 		vt		ON den.ValueTypeID = vt.ValueTypeID 
	LEFT OUTER JOIN CasinoLayout.tbl_Currencies 		cu		ON cu.CurrencyID = vt.CurrencyID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations SDENO ON SDENO.StockCompositionID = SourceLFID.StockCompositionID and SDENO.DenoID = den.DenoID
	LEFT OUTER JOIN CasinoLayout.StockComposition_Denominations DDENO ON DDENO.StockCompositionID = DestLFID.StockCompositionID and DDENO.DenoID = den.DenoID
	LEFT OUTER JOIN FloorActivity.tbl_UserAccesses 	DUAID   	ON DUAID.UserAccessID = Accounting.tbl_Transactions.DestUserAccessID 
WHERE   (Accounting.tbl_Transactions.TrCancelID is null)

GO
