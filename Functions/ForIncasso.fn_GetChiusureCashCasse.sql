SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO








CREATE FUNCTION [ForIncasso].[fn_GetChiusureCashCasse] 
(
@gaming			DATETIME
)

RETURNS @CassaResults TABLE 
(
	Tag					VARCHAR(16),
	CurrencyID			INT,
	Acronim				VARCHAR(4),
	ValueTypeID			INT,
	ValueTypeName		VARCHAR(64),
	StockID				INT,
	GamingDate			DATETIME,
	LastGamingDate		DATETIME,
	LastLFID			INT,
	OraApertura			DATETIME,
	OraChiusura			DATETIME,
	PrevGamingDate		DATETIME,
	PrevLifeCycleID		INT,
	RIPTransactionID	INT,
	MyRipTransID		INT,
	PrevChiusura		FLOAT,
	PrevConsegna		FLOAT,
	Ripristino			FLOAT,
	Apertura			FLOAT,
	Conteggio			FLOAT,
	Consegna			FLOAT,
	NelTrolley			FLOAT,
	NextRipristino		FLOAT,
	NextApertura		FLOAT,
	VersPoker			FLOAT,
	PRIMARY KEY CLUSTERED 
	(
		StockID ASC,CurrencyID ASC,ValueTypeID ASC,GamingDate ASC
	)
)
--WITH SCHEMABINDING
AS
BEGIN

/*



DECLARE @gaming DATETIME

SET @gaming = '12.14.2021'

select * from [ForIncasso].[fn_GetChiusureCashCasse]  (@gaming)


--*/
DECLARE @stocktypeid INT
SET @stocktypeid = 4
--go with trolley
INSERT INTO @CassaResults
(
    Tag,
    CurrencyID,
    Acronim,
    ValueTypeID,
    ValueTypeName,
    StockID,
    GamingDate,
    LastGamingDate,
    LastLFID,
    OraApertura,
    OraChiusura,
    PrevGamingDate,
    PrevLifeCycleID,
    RIPTransactionID,
    MyRipTransID,
    PrevChiusura,
    PrevConsegna,
    Ripristino,
    Apertura,
    Conteggio,
    Consegna,
    NelTrolley,
    NextRipristino,
    NextApertura,
    VersPoker
)
/*



DECLARE @gaming DATETIME
DECLARE @stocktypeid INT
SET @stocktypeid = 4

SET @gaming = '12.29.2021'
--select * FROM [Accounting].[fn_GetStockLifeCycleInfo] (@gaming, @stocktypeid) where stockid = 37
--*/
SELECT
	s.Tag,
	sc.CurrencyID,
	sc.CurrencyAcronim									AS Acronim,
	sc.ValueTypeID,
	sc.ValueTypeName,
	s.StockID,
	s.GamingDate,
	s.LastGamingDate,
	s.LastLFID,
	s.OraApertura,
	s.OraChiusura,
	s.PrevGamingDate ,
	s.PrevLifeCycleID,
	s.RIPTransactionID,
	s.MyRipTransID,
	ISNULL((prevch.Quantity),0)							AS PrevChiusura,
	ISNULL((prevcon.Quantity),0)						AS PrevConsegna,
	ISNULL((myrip.Quantity),0)							AS Ripristino,
	ISNULL((prevch.Quantity),0) 
	--		- ISNULL((prevcon.Quantity),0) 
			+ ISNULL((myrip.Quantity),0) 					AS Apertura,
	ISNULL((ch.Quantity),0) + ISNULL((con.Quantity),0)	AS Conteggio,	
	ISNULL((con.Quantity),0)							AS Consegna,
	ISNULL((ch.Quantity),0)								AS NelTrolley,	
	ISNULL((rip.Quantity),0)							AS NextRipristino,
	ISNULL((ch.Quantity),0) 
	--	- ISNULL((con.Quantity),0) 
		+ ISNULL((rip.Quantity),0) 						AS NextApertura,
	ISNULL(verpok.Quantity,0)							AS VersPoker
FROM Accounting.fn_GetStockLifeCycleInfo (@gaming, @stocktypeid) AS s
INNER JOIN 
(
	SELECT sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim,den.ValueTypeID,den.ValueTypeName
	FROM CasinoLayout.StockComposition_Denominations sc
	INNER JOIN CasinoLayout.vw_AllDenominations den ON den.DenoID = sc.DenoID
	WHERE den.IsFisical = 1 AND den.CurrencyID IN(0,4) --escludi valute straniere
	--WHERE den.ValueTypeID IN(1,2,3,7,36,42,59) --solo gettoni chf,gioco euro, euro e poker

	GROUP BY sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim,den.ValueTypeID,den.ValueTypeName
) sc ON sc.StockCompositionID = s.StockCompositionID
LEFT OUTER	JOIN  
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleID,
	ValueTypeID
	FROM [Accounting].[vw_AllSnapshotDenominations] 
	WHERE SnapshotTypeID = 3 --Chiusura
	GROUP BY CurrencyID,
	LifeCycleID,
	ValueTypeID
) prevch ON s.PrevLifeCycleID = prevch.LifeCycleID AND prevch.CurrencyID = sc.CurrencyID AND prevch.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID,
	ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
	ValueTypeID
)prevcon ON prevcon.TransactionID = s.PrevConTransactionID AND prevcon.CurrencyID = sc.CurrencyID AND prevcon.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID,
			ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
			ValueTypeID

)  rip ON rip.TransactionID = s.RIPTransactionID AND rip.CurrencyID = sc.CurrencyID AND rip.ValueTypeID = sc.ValueTypeID

LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
		TransactionID,
		CurrencyID,
		ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
			ValueTypeID

) myrip ON myrip.TransactionID = s.MyRipTransID AND myrip.CurrencyID = sc.CurrencyID  AND myrip.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID,
			ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
			ValueTypeID


) con ON con.TransactionID = s.CONTransactionID AND con.CurrencyID = sc.CurrencyID  AND con.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(	
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleSnapshotID,
			ValueTypeID
	FROM [Accounting].[vw_AllSnapshotDenominations]
	GROUP BY CurrencyID,
			LifeCycleSnapshotID,
			ValueTypeID
) ch ON ch.LifeCycleSnapshotID = s.ChiusuraSnapshotID AND ch.CurrencyID = sc.CurrencyID  AND ch.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
		DestLifeCycleID,
		CurrencyID,
		ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID = 59--pokerchips
	AND SourceStockID = 31 AND OpTypeID = 4
	AND DestLifeCycleID IS NOT NULL --onlz if accepted bz cassa centra;e
	GROUP BY CurrencyID,
			DestLifeCycleID,
			ValueTypeID
)  verpok ON verpok.DestLifeCycleID = s.LastLFID AND verpok.CurrencyID = sc.CurrencyID AND verpok.ValueTypeID = sc.ValueTypeID
WHERE s.LastGamingDate = @gaming

SET @stocktypeid = 7
--go with cc
INSERT INTO @CassaResults
(
    Tag,
    CurrencyID,
    Acronim,
    ValueTypeID,
    ValueTypeName,
    StockID,
    GamingDate,
    LastGamingDate,
    LastLFID,
    OraApertura,
    OraChiusura,
    PrevGamingDate,
    PrevLifeCycleID,
    RIPTransactionID,
    MyRipTransID,
    PrevChiusura,
    PrevConsegna,
    Ripristino,
    Apertura,
    Conteggio,
    Consegna,
    NelTrolley,
    NextRipristino,
    NextApertura,
    VersPoker
)
/*



DECLARE @gaming DATETIME
DECLARE @stocktypeid INT
SET @stocktypeid = 7

SET @gaming = '12.15.2021'
--select * FROM [Accounting].[fn_GetStockLifeCycleInfo] (@gaming, @stocktypeid) AS s order by Stockid
--*/
SELECT
	s.Tag,
	sc.CurrencyID,
	sc.CurrencyAcronim									AS Acronim,
	sc.ValueTypeID,
	sc.ValueTypeName,
	s.StockID,
	s.GamingDate,
	s.LastGamingDate,
	s.LastLFID,
	s.OraApertura,
	s.OraChiusura,
	s.PrevGamingDate ,
	s.PrevLifeCycleID,
	s.RIPTransactionID,
	s.MyRipTransID,
	ISNULL((prevch.Quantity),0)							AS PrevChiusura,
	ISNULL((prevcon.Quantity),0)						AS PrevConsegna,
	ISNULL((myrip.Quantity),0)							AS Ripristino,
	ISNULL((prevch.Quantity),0) 
--			- ISNULL((prevcon.Quantity),0) 
			+ ISNULL((myrip.Quantity),0) 				AS Apertura,
	ISNULL((ch2.Quantity),0) + ISNULL((con.Quantity),0)	AS Conteggio,	
	ISNULL((con.Quantity),0)							AS Consegna,
	ISNULL((ch2.Quantity),0)							AS NelTrolley,	
	ISNULL((rip.Quantity),0)							AS NextRipristino,
	ISNULL((ch2.Quantity),0) 
		- ISNULL((con.Quantity),0) 
		+ ISNULL((rip.Quantity),0) 						AS NextApertura,
	ISNULL(verpok.Quantity,0)							AS VersPoker
FROM Accounting.fn_GetStockLifeCycleInfo (@gaming, @stocktypeid) AS s
INNER JOIN 
(
	SELECT sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim,den.ValueTypeID,den.ValueTypeName
	FROM CasinoLayout.StockComposition_Denominations sc
	INNER JOIN CasinoLayout.vw_AllDenominations den ON den.DenoID = sc.DenoID
	WHERE den.IsFisical = 1 AND den.CurrencyID IN(0,4) --escludi valute straniere
	--WHERE den.ValueTypeID IN(1,2,3,7,36,42,59) --solo gettoni chf,gioco euro, euro e poker

	GROUP BY sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim,den.ValueTypeID,den.ValueTypeName
) sc ON sc.StockCompositionID = s.StockCompositionID
LEFT OUTER	JOIN  
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleID,
	ValueTypeID
	FROM [Accounting].[vw_AllSnapshotDenominations] 
	WHERE SnapshotTypeID = 3 --Chiusura
	GROUP BY CurrencyID,
	LifeCycleID,
	ValueTypeID
) prevch ON s.PrevLifeCycleID = prevch.LifeCycleID AND prevch.CurrencyID = sc.CurrencyID AND prevch.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID,
	ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
	ValueTypeID
)prevcon ON prevcon.TransactionID = s.PrevConTransactionID AND prevcon.CurrencyID = sc.CurrencyID AND prevcon.ValueTypeID = sc.ValueTypeID

LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
		TransactionID,
		CurrencyID,
		ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
			ValueTypeID

) myrip ON myrip.TransactionID = s.MyRipTransID AND myrip.CurrencyID = sc.CurrencyID  AND myrip.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID,
			ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
			ValueTypeID


) con ON con.TransactionID = s.CONTransactionID AND con.CurrencyID = sc.CurrencyID  AND con.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(	
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleSnapshotID,
			ValueTypeID
	FROM [Accounting].[vw_AllSnapshotDenominations]
	GROUP BY CurrencyID,
			LifeCycleSnapshotID,
			ValueTypeID
) ch2 ON ch2.LifeCycleSnapshotID = s.ChiusuraSnapshotID AND ch2.CurrencyID = sc.CurrencyID  AND ch2.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID,
			ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	GROUP BY CurrencyID,
			TransactionID,
			ValueTypeID

)  rip ON rip.TransactionID = s.RIPTransactionID AND rip.CurrencyID = sc.CurrencyID AND rip.ValueTypeID = sc.ValueTypeID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
		DestLifeCycleID,
		CurrencyID,
		ValueTypeID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID = 59--pokerchips
	AND SourceStockID = 31 AND OpTypeID = 4
	AND DestLifeCycleID IS NOT NULL --onlz if accepted bz cassa centra;e
	GROUP BY CurrencyID,
			DestLifeCycleID,
			ValueTypeID
)  verpok ON verpok.DestLifeCycleID = s.LastLFID AND verpok.CurrencyID = sc.CurrencyID AND verpok.ValueTypeID = sc.ValueTypeID
WHERE s.LastGamingDate = @gaming


RETURN
END
GO
