SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [ForIncasso].[fn_GetCashRipristinato]
(
    @gaming DATETIME,
	@StockTypeID INT
)
RETURNS @CashRipristinato TABLE (
	StockID				INT,
	StockTypeID			INT,
	LifeCycleID			INT,
	GamingDate			DATETIME,
	Tag					VARCHAR(16),
	Denomination		float,
	DenoID				INT, 
	ValueTypeID			INT, 
	ValueTypeName		VARCHAR(32),
	Acronim				VARCHAR(4),
	CurrencyID			INT,
	Chiusura			INT,
	Ripristino			INT,
	Apertura			INT,
	PRIMARY KEY CLUSTERED (StockID,DenoID)
	)
--WITH SCHEMABINDING
AS
BEGIN

	/*
declare     @gaming DATETIME,
	@StockTypeID INT

set @gaming = '4.6.2020'
set	@StockTypeID = 4
--*/

DECLARE @denos TABLE (
DenoID INT, Denomination FLOAT,ValueTypeName VARCHAR(32),ValueTypeID INT, Acronim VARCHAR(3),CurrencyID INT,
PRIMARY KEY (DenoID) 
)

INSERT INTO @denos
(
    DenoID,
	Denomination,
	ValueTypeID,
	ValueTypeName, 
	Acronim,
	CurrencyID
)
SELECT 
	DenoID,
	Denomination,
	ValueTypeID,
	ValueTypeName, 
	CurrencyAcronim,
	CurrencyID
FROM CasinoLayout.vw_AllDenominations 
WHERE DenoID IN (
24	,
25	,
26	,
27	,
28	,
29	,
31	,
32	,
33	,
34	,
35	,
36	,
37	,
47	,
48	,
137	,
138)  
--SELECT d.DenoID FROM @Denos d

INSERT INTO @CashRipristinato
(
	StockID				,
	StockTypeID			,
	LifeCycleID			,
	GamingDate			,
	Tag					,
	Denomination		,
	DenoID				,
	ValueTypeID			,
	ValueTypeName		,
	Acronim				,
	CurrencyID			,
	Chiusura			,
	Ripristino			,
	Apertura
)
SELECT 
	s.StockID,
	s.StockTypeID,
	s.LastLFID,
	s.LastGamingDate,
	s.Tag,
	d.Denomination,
	d.DenoID,
	d.ValueTypeID,
	d.ValueTypeName,
	d.Acronim,
	d.CurrencyID,
	ISNULL(chiu.InStock,0) AS Chiusura ,
	--ISNULL(rip.Quantity,0) AS Ripristino 
	--if we did not ripirstinated the last GamingDate take it from the today ripsristino
	--valid for Stocks opened or reopened after being emptied
	CASE WHEN chiu.RipristinoTRID IS NOT NULL THEN ISNULL(rip.Quantity,0) ELSE ISNULL(rip2.Quantity,0) END AS Ripristino,
	ISNULL(chiu.InStock,0) +
	--ISNULL(rip.Quantity,0) AS Ripristino 
	--if we did not ripirstinated the last GamingDate take it from the today ripsristino
	--valid for Stocks opened or reopened after being emptied
	CASE WHEN chiu.RipristinoTRID IS NOT NULL THEN ISNULL(rip.Quantity,0) ELSE ISNULL(rip2.Quantity,0) END AS Apertura
	FROM @denos d
	CROSS JOIN Accounting.fn_GetStockLifeCycleInfo (@gaming,@StockTypeID) s
	INNER JOIN [Accounting].[vw_AllChiusuraConsegnaRipristino] c ON c.LifeCycleID = s.LastLFID 
	LEFT OUTER JOIN Accounting.vw_AllChiusuraConsegnaDenominations chiu ON chiu.LifeCycleID = s.LastLFID AND chiu.DenoID = d.DenoID
	LEFT OUTER JOIN [Accounting].[vw_AllTransactionDenominations] rip on rip.TransactionID = s.RIPTransactionID and d.DenoID = rip.DenoID



	--this is beacuse we ripristinate the stock fom scratch and not from a previuos Chiusura
	LEFT OUTER JOIN [Accounting].[vw_AllTransactionDenominations] rip2 on rip2.SourceStockTypeID = 2 --source is a minstock
	AND d.DenoID = rip2.DenoID 
	AND rip2.SourceGamingDate = @gaming  --ripristinated today
	AND rip2.OpTypeID = 5 --only ripristino
	AND rip2.DestStockID = c.StockID


RETURN

END
GO
