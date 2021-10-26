SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [Accounting].[vw_AllChiusuraConsegnaRipristino]
WITH SCHEMABINDING
AS
SELECT 
	st.StockID,
	st.StockTypeID,
	st.Tag,
	LF.GamingDate,
	LF.LifeCycleID,
	lf.StockCompositionID,
	AP.SnapshotTimeLoc AS AperturaTime,
	--CHI.TotalCHF as Chiusura,
	CHI.LifeCycleSnapshotID AS ChiusuraSnapshotID,
	CHI.SnapshotTimeLoc AS ChiusuraTime,
	CHI.SnapshotTime	AS ChiusuraTimeUTC,
	--CON.TotalForSource as Consegna,
	CON.TransactionID AS CONTransactionID,
	CON.DestLifeCycleID AS ConsegnaDestLifeCycleID,
	--RIP.TotalForSource as Ripristino,
	RIP.TransactionID AS RIPTransactionID,
	RIP.SourceGamingDate AS RipGamingDate,
	RIP.DestLifeCycleID AS RipDestLifeCycleID,
	RIP.SourceStockID	AS RipSourceStockID,
	RIP.RipSourceLifeCycleID,
	RIP.ReopenGamingDate,
	RIP.ReopenLifeCycleID
FROM Accounting.tbl_LifeCycles LF
--consider only lifecycles with a valid apertura
INNER JOIN  Accounting.tbl_Snapshots AP 
	ON LF.LifeCycleID = AP.LifeCycleID
	AND SnapshotTypeID = 1 --only apertura snapshots
	AND LCSnapShotCancelID IS NULL
LEFT OUTER JOIN CasinoLayout.Stocks st ON st.StockID = LF.StockID
LEFT OUTER JOIN Accounting.tbl_Snapshots CHI 
	ON LF.LifeCycleID = CHI.LifeCycleID
	AND CHI.SnapshotTypeID = 3 --only Chiusura snapshots
	AND CHI.LCSnapShotCancelID IS NULL

--go with Consegna
LEFT OUTER JOIN 
( 
	SELECT 
	tr1.SourceLifeCycleID,
	tr1.TransactionID,
	tr1.DestLifeCycleID 
	FROM Accounting.tbl_Transactions tr1 
	WHERE tr1.OpTypeID = 6 --only Consegna operations
	AND tr1.TrCancelID IS NULL
)  CON ON CON.SourceLifeCycleID = LF.LifeCycleID 

--look for ripristino caused by this Consegna
LEFT OUTER JOIN 
( 
	SELECT  
		msLFID.StockID			AS SourceStockID,
		tr2.TransactionID		,
		msLFID.GamingDate		AS SourceGamingDate,
		msLFID.LifeCycleID		AS RipSourceLifeCycleID,
		RIPDestLF.GamingDate	AS ReopenGamingDate,
		RIPDestLF.LifeCycleID	AS ReopenLifeCycleID,
		tr2.DestStockID,
		tr2.DestLifeCycleID
	FROM Accounting.tbl_Transactions tr2 
	--look for transactions of type ripristino whose source lfid is the destlfid of some transaction (the Consegna) for which
	--the StockID was the source  
	INNER JOIN Accounting.tbl_LifeCycles msLFID ON tr2.SourceLifeCycleID = msLFID.LifeCycleID 
	--if it as been accepted do return also reopen information
	LEFT OUTER JOIN Accounting.tbl_LifeCycles RIPDestLF	ON RIPDestLF.LifeCycleID = tr2.DestLifeCycleID
	WHERE tr2.OpTypeID = 5 AND msLFID.StockID = 31 --only ripristino by Mainstock
	AND tr2.TrCancelID IS NULL
) RIP 
--the rispristion has been created for me the same GamingDate of th Consegna by Mainstock
ON LF.StockID = RIP.DestStockID AND LF.GamingDate = RIP.SourceGamingDate
GO
