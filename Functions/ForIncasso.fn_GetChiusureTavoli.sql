SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO







CREATE FUNCTION [ForIncasso].[fn_GetChiusureTavoli] 
(
@gaming			DATETIME
)

RETURNS @TableResults TABLE 
(
	Tag					VARCHAR(16),
	CurrencyID			INT,
	Acronim				VARCHAR(4),
	StockID				INT,
	MinBet				INT,
	GamingDate			DATETIME,
	LastGamingDate		DATETIME,
	LastLFID			INT,
	OraApertura			DATETIME,
	OraChiusura			DATETIME,
	PrevGamingDate		DATETIME,
	PrevLifeCycleID		INT,
	RIPTransactionID	INT,
	MyRipTransID		INT,
	PrevChiusura		INT,
	PrevConsegna		INT,
	Ripristino			INT,
	Apertura			INT,
	Consegna			INT,
	Chiusura			INT,
	NextRipristino		INT,
	Gone				VARCHAR(16),
	NextApertura		INT,
	Fills				INT,
	Credits				INT,
	EstimatedDrop		INT,
	CashBox				INT,
	Tronc				FLOAT,
	LuckyChips			INT,
	PRIMARY KEY CLUSTERED 
	(
		StockID ASC,CurrencyID ASC,GamingDate ASC
	)
)
--WITH SCHEMABINDING
AS
BEGIN

/*



DECLARE @gaming DATETIME

SET @gaming = '11.09.2021'

select * from [ForIncasso].[fn_GetChiusureTavoli] (@gaming)


--*/
DECLARE @stocktypeid INT
SET @stocktypeid = 1
--go with stock status of tables LG
INSERT INTO @TableResults
(
    Tag,
    CurrencyID,
    Acronim,
    StockID,
    MinBet,
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
    Consegna,
    Chiusura,
    NextRipristino,
    Gone,
    NextApertura,
    Fills,
    Credits,
    EstimatedDrop,
    CashBox,
    Tronc,
    LuckyChips
)
/*



DECLARE @gaming DATETIME

SET @gaming = '11.09.2021'
--select * FROM [Accounting].[fn_GetStockLifeCycleInfo] (@gaming, 23) AS s order by Stockid
--*/
SELECT
	s.Tag,
	sc.CurrencyID,
	sc.CurrencyAcronim									AS Acronim,
	s.StockID,
	s.MinBet,
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
	CASE 
		WHEN s.PrevGamingDate < '3.23.2017' THEN --beforebig change
			ISNULL((prevch.Quantity),0) 
			- ISNULL((prevcon.Quantity),0) 
			+ ISNULL((myrip.Quantity),0) 		
		ELSE
			ISNULL((prevch.Quantity),0)  
			+ ISNULL((myrip.Quantity),0)
	END													AS Apertura,
	ISNULL((con.Quantity),0)							AS Consegna,
	CASE WHEN s.LastGamingDate < '3.23.2017' THEN
		ISNULL((ch2.Quantity),0) --beforebig change		
	ELSE
		ISNULL((ch2.Quantity),0) 
		+ ISNULL((con.Quantity),0)		
	END													AS Chiusura,
	ISNULL((rip.Quantity),0)							AS NextRipristino,
	CASE WHEN s.LastGamingDate < '3.23.2017' THEN 'bef big change' ELSE NULL END AS Gone,
	CASE WHEN s.LastGamingDate < '3.23.2017' THEN--beforebig change
		ISNULL((ch2.Quantity),0) 
		- ISNULL((con.Quantity),0) 
		+ ISNULL((rip.Quantity),0) 	
	ELSE
		ISNULL((ch2.Quantity),0) 
		+ ISNULL((rip.Quantity),0)
	END													AS NextApertura,
	ISNULL((fil.Quantity),0)							AS Fills,
	ISNULL((cre.Quantity),0)							AS Credits,
	ISNULL(exDrop.Quantity,0)							AS EstimatedDrop,
	ISNULL(box.Quantity,0)								AS CashBox,
	ISNULL(tronc.Quantity,0)							AS Tronc,
	ISNULL(luc.Quantity,0)							AS LuckyChips
FROM Accounting.fn_GetStockLifeCycleInfo (@gaming, @stocktypeid) AS s
INNER JOIN 
(
	SELECT sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim
	FROM CasinoLayout.StockComposition_Denominations sc
	INNER JOIN CasinoLayout.vw_AllDenominations den ON den.DenoID = sc.DenoID
	GROUP BY sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim
) sc ON sc.StockCompositionID = s.StockCompositionID
LEFT OUTER	JOIN  
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleID
	FROM [Accounting].[vw_AllSnapshotDenominations] 
	WHERE SnapshotTypeID = 3 --Chiusura
	AND ValueTypeID IN(1,36,42) --solo gettoni gioco eur, chf e eur
	--AND LifeCycleID = 175279
	GROUP BY CurrencyID,
	LifeCycleID
) prevch ON s.PrevLifeCycleID = prevch.LifeCycleID AND prevch.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(1,36,42) --solo gettoni  gioco eur, chf e eur
	GROUP BY CurrencyID,
			TransactionID
)prevcon ON prevcon.TransactionID = s.PrevConTransactionID AND prevcon.CurrencyID = sc.CurrencyID

LEFT OUTER	JOIN (
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(1,36,42) --solo gettoni  gioco eur, chf e eur
	GROUP BY CurrencyID,
			TransactionID

) myrip ON myrip.TransactionID = s.MyRipTransID AND myrip.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(1,36,42) --solo gettoni  gioco eur, chf e eur
	GROUP BY CurrencyID,
			TransactionID


) con ON con.TransactionID = s.CONTransactionID AND con.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(	
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleSnapshotID
	FROM [Accounting].[vw_AllSnapshotDenominations]
	WHERE ValueTypeID IN(1,36,42) --solo gettoni 
	GROUP BY CurrencyID,
			LifeCycleSnapshotID
) ch2 ON ch2.LifeCycleSnapshotID = s.ChiusuraSnapshotID AND ch2.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(1,36,42) --solo gettoni  gioco eur, chf e eur
	GROUP BY CurrencyID,
			TransactionID

)  rip ON rip.TransactionID = s.RIPTransactionID AND rip.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT 
		SourceLifeCycleID AS LifeCycleID,
		CAST(SUM(Denomination * Quantity) AS INT) AS Quantity, 
		CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 1 --fill
	AND ValueTypeID IN(1,36,42) --solo gettoni  gioco eur, chf e eur
	GROUP BY SourceLifeCycleID,CurrencyID
) fil ON fil.LifeCycleID = s.LastLFID AND fil.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN  
(
	SELECT SourceLifeCycleID AS LifeCycleID,
		CAST(SUM(Denomination * Quantity) AS INT) AS Quantity, 
		CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 4 --credit
	AND ValueTypeID IN(1,36,42) --solo gettoni  gioco eur, chf e eur
	GROUP BY SourceLifeCycleID,
		CurrencyID
) cre ON cre.LifeCycleID = s.LastLFID AND cre.CurrencyID = sc.CurrencyID
LEFT OUTER JOIN 
(
  SELECT GamingDate,StockID,CurrencyID,SUM(Quantity*Denomination) AS Quantity
  FROM [Accounting].[vw_AllConteggiDenominations]
  WHERE SnapshotTypeID = 7 --conteggio cash box tavoli
  GROUP BY GamingDate,StockID,CurrencyID
) box ON box.StockID = s.StockID AND box.GamingDate = s.GamingDate AND sc.CurrencyID = box.CurrencyID

LEFT OUTER JOIN  
(
  SELECT GamingDate,StockID,CurrencyID,SUM(Quantity*Denomination) AS Quantity
  FROM [Accounting].[vw_AllConteggiDenominations]
  WHERE SnapshotTypeID = 8 --conteggio tronc box tavoli 
  GROUP BY GamingDate,CurrencyID,StockID
) tronc ON tronc.StockID = s.StockID AND tronc.GamingDate = s.GamingDate AND sc.CurrencyID = tronc.CurrencyID

LEFT OUTER	JOIN 
(
	SELECT LifeCycleSnapshotID,
		4 AS CurrencyID,
		CAST((Denomination * Quantity) AS INT) AS Quantity
	FROM [Accounting].[vw_AllSnapshotDenominations]  
	WHERE DenoID = 13
) exDrop ON exDrop.LifeCycleSnapshotID = s.ChiusuraSnapshotID AND sc.CurrencyID = tronc.CurrencyID
LEFT OUTER JOIN 
(
	SELECT TotCount AS Quantity,
	4 AS CurrencyID,
	GamingDate,
	StockID
	FROM [Accounting].[vw_TableLuckyChipsContato]
) luc ON luc.StockID = s.StockID AND luc.GamingDate = s.GamingDate AND luc.CurrencyID = sc.CurrencyID
WHERE  NOT (s.StockID = 82 AND s.GamingDate = '7.14.2019') --exclude faked first UTH1 Lifecycle





--ora vai con i tavoli poker
SET @stocktypeid = 23
--go with stock status of tables LG
INSERT INTO @TableResults
(
    Tag,
    CurrencyID,
    Acronim,
    StockID,
    MinBet,
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
    Consegna,
    Chiusura,
    NextRipristino,
    Gone,
    NextApertura,
    Fills,
    Credits,
    EstimatedDrop,
    CashBox,
    Tronc,
    LuckyChips
)
/*



DECLARE @gaming DATETIME,@stocktypeid INT
SET @stocktypeid = 23

SET @gaming = '11.10.2021'
--select * FROM [Accounting].[fn_GetStockLifeCycleInfo] (@gaming, 1) AS s order by Stockid
--*/
SELECT
	s.Tag,
	sc.CurrencyID,
	sc.CurrencyAcronim									AS Acronim,
	s.StockID,
	s.MinBet,
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
	CASE 
		WHEN s.PrevGamingDate < '3.23.2017' THEN --beforebig change
			ISNULL((prevch.Quantity),0) 
			- ISNULL((prevcon.Quantity),0) 
			+ ISNULL((myrip.Quantity),0) 		
		ELSE
			ISNULL((prevch.Quantity),0)  
			+ ISNULL((myrip.Quantity),0)
	END													AS Apertura,
	ISNULL((con.Quantity),0)							AS Consegna,
	CASE WHEN s.LastGamingDate < '3.23.2017' THEN
		ISNULL((ch2.Quantity),0) --beforebig change		
	ELSE
		ISNULL((ch2.Quantity),0) 
		+ ISNULL((con.Quantity),0)		
	END													AS Chiusura,
	ISNULL((rip.Quantity),0)							AS NextRipristino,
	CASE WHEN s.LastGamingDate < '3.23.2017' THEN 'bef big change' ELSE NULL END AS Gone,
	CASE WHEN s.LastGamingDate < '3.23.2017' THEN--beforebig change
		ISNULL((ch2.Quantity),0) 
		- ISNULL((con.Quantity),0) 
		+ ISNULL((rip.Quantity),0) 	
	ELSE
		ISNULL((ch2.Quantity),0) 
		+ ISNULL((rip.Quantity),0)
	END													AS NextApertura,
	ISNULL((fil.Quantity),0)							AS Fills,
	ISNULL((cre.Quantity),0)							AS Credits,
	0													AS EstimatedDrop,
	ISNULL(box.Quantity,0)								AS CashBox,
	ISNULL(tronc.Quantity,0)							AS Tronc,
	0													AS LuckyChips
FROM Accounting.fn_GetStockLifeCycleInfo (@gaming, @stocktypeid) AS s
INNER JOIN 
(
	SELECT sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim
	FROM CasinoLayout.StockComposition_Denominations sc
	INNER JOIN CasinoLayout.vw_AllDenominations den ON den.DenoID = sc.DenoID
	GROUP BY sc.StockCompositionID,den.CurrencyID,den.CurrencyAcronim
) sc ON sc.StockCompositionID = s.StockCompositionID
LEFT OUTER	JOIN  
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleID
	FROM [Accounting].[vw_AllSnapshotDenominations] 
	WHERE SnapshotTypeID = 3 --Chiusura
	AND ValueTypeID IN(59) --solo gettoni poker
	GROUP BY CurrencyID,
	LifeCycleID
) prevch ON s.PrevLifeCycleID = prevch.LifeCycleID AND prevch.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(59) --solo gettoni poker
	GROUP BY CurrencyID,
			TransactionID
)prevcon ON prevcon.TransactionID = s.PrevConTransactionID AND prevcon.CurrencyID = sc.CurrencyID

LEFT OUTER	JOIN (
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(59) --solo gettoni poker
	GROUP BY CurrencyID,
			TransactionID

) myrip ON myrip.TransactionID = s.MyRipTransID AND myrip.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(59) --solo gettoni poker
	GROUP BY CurrencyID,
			TransactionID


) con ON con.TransactionID = s.CONTransactionID AND con.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(	
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	CurrencyID,
	LifeCycleSnapshotID
	FROM [Accounting].[vw_AllSnapshotDenominations]
	WHERE ValueTypeID IN(59) --solo gettoni poker
	GROUP BY CurrencyID,
			LifeCycleSnapshotID
) ch2 ON ch2.LifeCycleSnapshotID = s.ChiusuraSnapshotID AND ch2.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT CAST(SUM(Denomination * Quantity) AS INT) AS Quantity,
	TransactionID,
	CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE ValueTypeID IN(59) --solo gettoni poker
	GROUP BY CurrencyID,
			TransactionID

)  rip ON rip.TransactionID = s.RIPTransactionID AND rip.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN 
(
	SELECT 
		SourceLifeCycleID AS LifeCycleID,
		CAST(SUM(Denomination * Quantity) AS INT) AS Quantity, 
		CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 1 --fill
	AND ValueTypeID IN(59) --solo gettoni poker
	GROUP BY SourceLifeCycleID,CurrencyID
) fil ON fil.LifeCycleID = s.LastLFID AND fil.CurrencyID = sc.CurrencyID
LEFT OUTER	JOIN  
(
	SELECT SourceLifeCycleID AS LifeCycleID,
		CAST(SUM(Denomination * Quantity) AS INT) AS Quantity, 
		CurrencyID
	FROM [Accounting].[vw_AllTransactionDenominations] 
	WHERE OpTypeID = 4 --credit
	AND ValueTypeID IN(59) --solo gettoni poker
	GROUP BY SourceLifeCycleID,
		CurrencyID
) cre ON cre.LifeCycleID = s.LastLFID AND cre.CurrencyID = sc.CurrencyID
LEFT OUTER JOIN 
(
  SELECT GamingDate,StockID,CurrencyID,SUM(Quantity*Denomination) AS Quantity
  FROM [Accounting].[vw_AllConteggiDenominations]
  WHERE SnapshotTypeID = 22  AND ValueTypeID = 59--conteggio cash box poker (solo gettoni poker)
  GROUP BY GamingDate,StockID,CurrencyID
) box ON box.StockID = s.StockID AND box.GamingDate = s.GamingDate AND sc.CurrencyID = box.CurrencyID

LEFT OUTER JOIN  
(
  SELECT 
		d.GamingDate,
		d.StockID,
		d.CurrencyID,
		SUM(d.Quantity*d.Denomination) AS Quantity
	  FROM [Accounting].[vw_AllConteggiDenominations] d
	  WHERE d.SnapshotTypeID = 23 AND d.ValueTypeID = 59--conteggio tronc poker eur (solo gettoni poker)
	  GROUP BY d.GamingDate,d.StockID,d.CurrencyID
) tronc ON tronc.StockID = s.StockID AND tronc.GamingDate = s.GamingDate AND sc.CurrencyID = tronc.CurrencyID
WHERE  NOT (s.StockID = 82 AND s.GamingDate = '7.14.2019') --exclude faked first UTH1 Lifecycle


RETURN
END
GO
