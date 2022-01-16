SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









CREATE VIEW [Accounting].[vw_AllSlotTransactions]
WITH SCHEMABINDING
AS
SELECT
		tr.OpTypeID,
		op.FName												AS OpTypeName,
		tr.SlotTransactionID
		,tr.[LifeCycleID]
		,lf.Tag
		,lf.StockID
		,tr.AmountCents
		,tr.Currency	
		,tr.ExchangeRate
		,CASE WHEN tr.Currency = 4 THEN 1 ELSE 0 END AS IsSfr
		,CONVERT(FLOAT, tr.AmountCents) / 100.0						AS Importo
		,CONVERT(FLOAT, tr.AmountCents) / 100.0	* tr.ExchangeRate	AS CHF
		,tr.SlotNr
	  ,(CONVERT([int],tr.[SlotNr]/power((2),(8))&0xFF)) AS Bank
	  ,(CONVERT([int],tr.[SlotNr]&0xFF)) AS Position
		,tr.IpAddr
		,GeneralPurpose.fn_UTCToLocal(1,tr.InsertTimeStampUTC)	AS IssueTimeLoc
		,GeneralPurpose.fn_UTCToLocal(1,tr.PaymentTimeUTC)	AS PaymentTimeLoc
		,lf.GamingDate
		--,tr.JackpotID
		,tr.jpID
		,tr.jpName
		,tr.JpInstance
		,tr.ValidationNumber
		,tr.PinCode
		,ua.SiteID
		,s.ComputerName
		,tr.Nota
FROM [Accounting].[tbl_SlotTransactions] tr
INNER JOIN CasinoLayout.OperationTypes op ON op.OpTypeID = tr.OpTypeID
INNER JOIN Accounting.vw_AllStockLifeCycles lf ON tr.LifeCycleID = lf.LifeCycleID
INNER JOIN FloorActivity.tbl_UserAccesses ua ON lf.UserAccessID = ua.UserAccessID
INNER JOIN CasinoLayout.Sites s ON s.SiteID = ua.SiteID
WHERE tr.CancelID IS NULL
GO
