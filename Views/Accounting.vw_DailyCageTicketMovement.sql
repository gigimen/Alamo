SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [Accounting].[vw_DailyCageTicketMovement]
WITH SCHEMABINDING
AS

SELECT	ISNULL(i.[LifeCycleID],r.[LifeCycleID]) AS LFID,
		ISNULL(i.[Tag],r.[Tag]) AS Tag,
		ISNULL(i.IsSfr,r.IsSfr) AS IsTicketSfr,
		ISNULL(i.IsDRGT,r.IsDRGT) AS IsDRGT,
		ISNULL(i.IsPromo,r.IsPromo) AS IsPromo,
		ISNULL(i.IssuedCount,0) AS IssuedCount,
		ISNULL(i.IssuedTotCents,0) AS IssuedTotCents,
		ISNULL(r.RedeemedCount,0) AS RedeemedCount,
		ISNULL(r.RedeemedTotCents,0) AS RedeemedTotCents

FROM
(
	SELECT tr.[LifeCycleID]
		,st.Tag
		  ,COUNT(*) AS IssuedCount
		  ,SUM(tr.AmountCents) AS IssuedTotCents
		  ,tr.IsSfr
		  ,tr.IsPromo
		  ,tr.IsDRGT
	FROM [Accounting].[tbl_TicketTransactions] tr
	INNER JOIN Accounting.tbl_LifeCycles lf ON tr.[LifeCycleID] = lf.LifeCycleID
	INNER JOIN CasinoLayout.Stocks st ON st.[StockID] = lf.StockID
	WHERE (IsVoided IS NULL OR IsVoided = 0)
	AND AmountCents < 0 --only issued tickets
	GROUP BY tr.[LifeCycleID],tr.IsSfr,tr.IsPromo,st.Tag,tr.IsDRGT
) i FULL OUTER JOIN 
(
	SELECT tr.[LifeCycleID]
		,st.Tag
		  ,COUNT(*) AS RedeemedCount
		  ,SUM(tr.AmountCents) AS RedeemedTotCents
		  ,tr.IsSfr
		  ,tr.IsPromo
		  ,tr.IsDRGT
	FROM [Accounting].[tbl_TicketTransactions] tr
	INNER JOIN Accounting.tbl_LifeCycles lf ON tr.[LifeCycleID] = lf.LifeCycleID
	INNER JOIN CasinoLayout.Stocks st ON st.[StockID] = lf.StockID
	WHERE (IsVoided IS NULL OR IsVoided = 0)
	AND AmountCents > 0 --only reddemed tickets
	GROUP BY tr.[LifeCycleID],tr.IsSfr,tr.IsPromo,st.Tag,tr.IsDRGT
) r 
ON r.[LifeCycleID] = i.[LifeCycleID] AND i.IsSfr = r.IsSfr AND i.IsPromo = r.IsPromo AND r.IsDRGT = i.IsDRGT




GO
