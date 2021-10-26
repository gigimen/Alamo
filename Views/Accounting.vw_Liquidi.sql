SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Accounting].[vw_Liquidi]
WITH SCHEMABINDING
AS
SELECT 	TOP 100 PERCENT
	LCCC.GamingDate ,
--1000 SFr bills
/*	CB1000.Quantity as Bills1000C,
	RB1000.Quantity as Bills1000R,
	CMSB1000.Quantity as Bills1000MS,
	(select sum(InitialQty) 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 24) as CAS1000,
*/	ISNULL(CB1000.Quantity,0) + 
	ISNULL(RB1000.Quantity,0) + 
	ISNULL(CMSB1000.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 24) AS Bills1000,
--200 SFr bills
/*	CB200.Quantity as Bills200C,
	RB200.Quantity as Bills200R,
	CMSB200.Quantity as Bills200MS,
	(select sum(InitialQty) 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 25) as CAS200,
*/	ISNULL(CB200.Quantity,0) + 
	ISNULL(RB200.Quantity,0) + 
	ISNULL(CMSB200.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 25) AS Bills200,
--100 SFr bills
/*	CB100.Quantity as Bills100C,
	RB100.Quantity as Bills100R,
	CMSB100.Quantity as Bills100MS,
	(select sum(InitialQty) 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 26) as CAS100,
*/	ISNULL(CB100.Quantity,0) + 
	ISNULL(RB100.Quantity,0) + 
	ISNULL(CMSB100.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 26) AS Bills100,
--50 SFr bills
/*	CB50.Quantity as Bills50C,
	RB50.Quantity as Bills50R,
	CMSB50.Quantity as Bills50MS,
	(select sum(InitialQty) 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 27) as CAS50,
*/	ISNULL(CB50.Quantity,0) + 
	ISNULL(RB50.Quantity,0) + 
	ISNULL(CMSB50.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 27) AS Bills50,
--20 SFr bills
/*	CB20.Quantity as Bills20C,
	RB20.Quantity as Bills20R,
	CMSB20.Quantity as Bills20MS,
	(select sum(InitialQty) 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 28) as CAS20,
*/	ISNULL(CB20.Quantity,0) + 
	ISNULL(RB20.Quantity,0) + 
	ISNULL(CMSB20.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 28) AS Bills20,
--10 SFr bills
/*	CB10.Quantity as Bills10C,
	RB10.Quantity as Bills10R,
	CMSB10.Quantity as Bills10MS,
	(select sum(InitialQty) 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 29) as CAS10,
*/	ISNULL(CB10.Quantity,0) + 
	ISNULL(RB10.Quantity,0) + 
	ISNULL(CMSB10.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 29) AS Bills10,
--1 SFr coins
/*	CM1.Quantity as Coins1CC,
	RM1.Quantity as Coins1CR,
	CMSM1.Quantity as Coins1MS,
	(select sum(InitialQty) 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 47) as CASM1,
*/	ISNULL(CM1.Quantity,0) + 
	ISNULL(RM1.Quantity,0) + 
	ISNULL(CMSM1.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 47) AS Coins1,
--Div coins
/*	CMDIV.Quantity * 0.01 as CoinsDIVCC,
	RMDIV.Quantity * 0.01 as CoinsDIVCR,
	CMSMDIV.Quantity * 0.01 as CoinsDIVMS,
	(select sum(InitialQty) * 0.01 
		from dbo.vw_CurrentStockDenominations
		where StockTypeID = 4 and DenoID = 48) as CASMDIV,
*/	(ISNULL(CMDIV.Quantity,0) + 
	ISNULL(RMDIV.Quantity,0) + 
	ISNULL(CMSMDIV.Quantity,0) +
	(SELECT SUM(InitialQty) 
			FROM CasinoLayout.vw_CurrentStockDenominations
			WHERE StockTypeID = 4 AND DenoID = 48) ) * 0.01 AS CoinsDiv
FROM Accounting.tbl_LifeCycles LCCC

--Chiusura cassa centrale
INNER JOIN Accounting.tbl_Snapshots SSCCC
ON SSCCC.LifeCycleID = LCCC.LifeCycleID AND SSCCC.SnapshotTypeID = 3 AND LCCC.StockID = 46  
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CB1000
ON CB1000.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CB1000.DenoID = 24
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CB200
ON CB200.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CB200.DenoID = 25
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CB100
ON CB100.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CB100.DenoID = 26
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CB50
ON CB50.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CB50.DenoID = 27
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CB20
ON CB20.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CB20.DenoID = 28
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CB10
ON CB10.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CB10.DenoID = 29
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CM1
ON CM1.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CM1.DenoID = 47
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMDIV
ON CMDIV.LifeCycleSnapshotID = SSCCC.LifeCycleSnapshotID AND CMDIV.DenoID = 48

--Ripristino CassaCentrale
INNER JOIN Accounting.tbl_Transactions RIP
ON RIP.DestStockID = LCCC.StockID AND TrCancelID IS NULL AND RIP.OpTypeID = 5
INNER JOIN Accounting.tbl_LifeCycles SRIP
ON SRIP.LifeCycleID = RIP.SourceLifeCycleID AND SRIP.GamingDate = LCCC.GamingDate
LEFT OUTER JOIN Accounting.tbl_TransactionValues RB1000
ON RB1000.TransactionID = RIP.TransactionID AND RB1000.DenoID = 24 
LEFT OUTER JOIN Accounting.tbl_TransactionValues RB200
ON RB200.TransactionID = RIP.TransactionID AND RB200.DenoID = 25
LEFT OUTER JOIN Accounting.tbl_TransactionValues RB100
ON RB100.TransactionID = RIP.TransactionID AND RB100.DenoID = 26
LEFT OUTER JOIN Accounting.tbl_TransactionValues RB50
ON RB50.TransactionID = RIP.TransactionID AND RB50.DenoID = 27
LEFT OUTER JOIN Accounting.tbl_TransactionValues RB20
ON RB20.TransactionID = RIP.TransactionID AND RB20.DenoID = 28
LEFT OUTER JOIN Accounting.tbl_TransactionValues RB10
ON RB10.TransactionID = RIP.TransactionID AND RB10.DenoID = 29
LEFT OUTER JOIN Accounting.tbl_TransactionValues RM1
ON RM1.TransactionID = RIP.TransactionID AND RM1.DenoID = 47
LEFT OUTER JOIN Accounting.tbl_TransactionValues RMDIV
ON RMDIV.TransactionID = RIP.TransactionID AND RMDIV.DenoID = 48

--Chiusura Main Stock
INNER JOIN Accounting.tbl_LifeCycles CMS
ON CMS.GamingDate = LCCC.GamingDate AND CMS.StockID = 31
INNER JOIN Accounting.tbl_Snapshots CMSSS
ON CMSSS.LifeCycleID = CMS.LifeCycleID AND CMSSS.SnapshotTypeID = 3
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSB1000
ON CMSB1000.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSB1000.DenoID = 24
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSB200
ON CMSB200.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSB200.DenoID = 25
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSB100
ON CMSB100.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSB100.DenoID = 26
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSB50
ON CMSB50.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSB50.DenoID = 27
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSB20
ON CMSB20.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSB20.DenoID = 28
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSB10
ON CMSB10.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSB10.DenoID = 29
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSM1
ON CMSM1.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSM1.DenoID = 47
LEFT OUTER JOIN Accounting.tbl_SnapshotValues CMSMDIV
ON CMSMDIV.LifeCycleSnapshotID = CMSSS.LifeCycleSnapshotID AND CMSMDIV.DenoID = 48
ORDER BY LCCC.GamingDate
GO
