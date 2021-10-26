SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [ForIncasso].[fn_GetChipsRipristinati]
(
    @gaming DATETIME,
	@StockTypeID INT
)
RETURNS @ChipsRipristinati TABLE (
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
	PRIMARY KEY CLUSTERED (StockID,DenoID)
	)
--WITH SCHEMABINDING
AS
BEGIN


/*

select * from [ForIncasso].[fn_GetChipsRipristinati] ('1.12.2020',1) order by ValueTypeID,DenoID
select * from [ForIncasso].[fn_GetChipsRipristinati] ('8.30.2020',2) order by ValueTypeID,DenoID
select * from [ForIncasso].[fn_GetChipsRipristinati] ('12.4.2019',4) order by ValueTypeID,DenoID
select * from [ForIncasso].[fn_GetChipsRipristinati] ('2.10.2019',7) order by ValueTypeID,DenoID

*/

/* ----------------------OLD way very slow------


INSERT INTO @ChipsRipristinati
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
	Chiusura			,
	Ripristino			
)
SELECT 
	s.StockID,
	@StockTypeID AS StockTypeID,
	s.LastLFID,
	s.LastGamingDate,
	s.Tag,
	d.Denomination,
	d.DenoID,
	d.ValueTypeID,
	d.ValueTypeName,
	d.CurrencyAcronim AS Acronim,
	ISNULL(chiu.InStock,0) AS Chiusura,
	--ISNULL(rip.Quantity,0) AS Ripristino 
	--if we did not ripirstinated the last GamingDate take it from the today ripsristino
	--valid for Stocks opened or reopened after being emptied
	CASE WHEN chiu.RipristinoTRID IS NOT NULL THEN ISNULL(rip.Quantity,0) ELSE ISNULL(rip2.Quantity,0) END AS Ripristino
	FROM Accounting.fn_GetStockLifeCycleInfo (
	   @gaming
	  ,@StockTypeID) s
	CROSS JOIN CasinoLayout.vw_AllDenominations d
	INNER JOIN [Accounting].[vw_AllChiusuraConsegnaRipristino] c ON c.LifeCycleID = s.LastLFID 
	LEFT OUTER JOIN Accounting.vw_AllChiusuraConsegnaDenominations chiu ON chiu.LifeCycleID = s.LastLFID AND chiu.DenoID = d.DenoID
	LEFT OUTER JOIN [Accounting].[vw_AllTransactionDenominations] rip on rip.TransactionID = s.RIPTransactionID and d.DenoID = rip.DenoID



	--this is beacuse we ripristinate the stock fom scratch and not from a previuos Chiusura
	LEFT OUTER JOIN [Accounting].[vw_AllTransactionDenominations] rip2 on rip2.SourceStockTypeID = 2 --source is a minstock
	AND d.DenoID = rip2.DenoID 
	AND rip2.SourceGamingDate = @gaming  --ripristinated today
	AND rip2.OpTypeID = 5 --only ripristino
	AND rip2.DestStockID = c.StockID


	WHERE d.DenoID IN(1,2,3,4,5,6,7,8,9,128,129,130,131,132,133,134,135,136,195,196,197,198,199,200,201,202,203)  

-------------------------------------*/


/*
	
declare     @gaming DATETIME,
	@StockTypeID INT

set @gaming = '1.12.2020'
set	@StockTypeID = 1
*/

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
WHERE DenoID IN(1,2,3,4,5,6,7,8,9,78,128,129,130,131,132,133,134,135,136,195,196,197,198,199,200,201,202,203)  

--SELECT d.DenoID FROM @Denos d

INSERT INTO @ChipsRipristinati
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
	Ripristino			
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
	CASE WHEN chiu.RipristinoTRID IS NOT NULL THEN ISNULL(rip.Quantity,0) ELSE ISNULL(rip2.Quantity,0) END AS Ripristino
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
