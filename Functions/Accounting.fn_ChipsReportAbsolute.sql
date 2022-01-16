SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [Accounting].[fn_ChipsReportAbsolute]
(
@gaming DATETIME,
@valuetypeid INT
)
/*
select * from [Accounting].[fn_ChipsReportAbsolute]( '12.31.2021',1)
order by stocktypeid,stockid

*/
RETURNS  @ret TABLE
(
	Tag			VARCHAR(32),
	StockID		INT,
	StockTypeID	INT,
	GamingDate	DATETIME,
	Chips10000	INT,
	Chips5000	INT,
	Chips1000	INT,
	Chips100	INT,
	Chips50		INT,
	Chips25		INT,
	Chips20		INT,
	Chips10		INT,
	Chips5		INT,
	Chips1		INT,
	LuckyChips	INT,
	TotalValue	INT
) 

--WITH SCHEMABINDING
AS
BEGIN

/*

DECLARE @gaming DATETIME,@valuetypeid INT
SET @gaming = '12.31.2021'
SET @valuetypeid = 59


DECLARE @ret TABLE
(
	Tag			VARCHAR(32),
	StockID		INT,
	StockTypeID	INT,
	GamingDate	DATETIME,
	Chips10000	INT,
	Chips5000	INT,
	Chips1000	INT,
	Chips100	INT,
	Chips50		INT,
	Chips20		INT,
	Chips10		INT,
	Chips5		INT,
	Chips1		INT,
	LuckyChips	INT,
	TotalValue	INT
) 
--*/
DECLARE @chipsreport TABLE
(
	Tag			VARCHAR(32),
	StockID		INT,
	StockTypeID	INT,
	GamingDate	DATETIME,
	Chips10000	INT,
	Chips5000	INT,
	Chips1000	INT,
	Chips100	INT,
	Chips50		INT,
	Chips25		INT,
	Chips20		INT,
	Chips10		INT,
	Chips5		INT,
	Chips1		INT,
	LuckyChips	INT,
	TotalValue	INT
)
DECLARE 
	@Chips10000		INT,
	@Chips5000		INT,
	@Chips1000		INT,
	@Chips100		INT,
	@Chips50		INT,
	@Chips25		INT,
	@Chips20		INT,
	@Chips10		INT,
	@Chips5			INT,
	@Chips1			INT,
	@LuckyChips		INT,
	@TotalValue		INT


DECLARE @ChipsRipristinati TABLE (
StockTypeID INT,
StockID		INT,
Tag			VARCHAR(32),
GamingDate	DATETIME,
ValueTypeID	INT,
DenoID		INT,
Denomination	FLOAT,
CurrencyID	INT,
Apertura	INT)

--tavoli
INSERT INTO @ChipsRipristinati
(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
SELECT 	StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Chiusura+Ripristino AS Apertura
from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,1) --TAVOLI
WHERE ValueTypeID = @valuetypeid

--Mainstock
INSERT INTO @ChipsRipristinati
(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
SELECT 	StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Chiusura+Ripristino AS Apertura
from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,2) --MS
WHERE ValueTypeID = @valuetypeid


--SMT
INSERT INTO @ChipsRipristinati
(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
SELECT 	StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Chiusura+Ripristino AS Apertura
from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,3) --SMT
WHERE ValueTypeID = @valuetypeid


--RISERVA
INSERT INTO @ChipsRipristinati
(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
SELECT 	StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Chiusura+Ripristino AS Apertura
from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,6) --RISERVA
WHERE ValueTypeID = @valuetypeid
--CASSE
INSERT INTO @ChipsRipristinati
(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
SELECT 	StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Chiusura+Ripristino AS Apertura
from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,7) --casse
WHERE ValueTypeID = @valuetypeid
--CC
IF @valuetypeid =59
--dobbiamo anche contare il versmento da MS 
	INSERT INTO @ChipsRipristinati
	(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
	SELECT 	StockTypeID,StockID,Tag,GamingDate,ValueTypeID,c.DenoID,Denomination,CurrencyID,
	Chiusura + Ripristino + ISNULL(vers.Quantity,0) AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,4) c--cc
	INNER JOIN 
	(
	/*
	DECLARE @gaming DATETIME,	@oggi VARCHAR(16)

	SET		@gaming = '12.19.2021'
	set 	@oggi = 'OGGI'


	--*/	
		SELECT 
		DenoID,
		DestLifeCycleID,
		[Quantity]
		from Accounting.vw_AllTransactionDenominations 
		WHERE ValueTypeID = 59--pokerchips
		AND SourceStockID = 31 AND OpTypeID = 4 AND DestStockID = 46 --cc
		AND DestLifeCycleID IS NOT NULL --onlz if accepted bz cassa centra;e
	) vers ON vers.DenoID = c.DenoID AND vers.DestLifeCycleID = c.LifeCycleID

	WHERE ValueTypeID = @valuetypeid
ELSE
	INSERT INTO @ChipsRipristinati
	(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
	SELECT 	StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,
	Chiusura+Ripristino AS Apertura
	from [ForIncasso].[fn_GetChipsRipristinati] (@gaming,4) --cc
	WHERE ValueTypeID = @valuetypeid
--dotazione

INSERT INTO @ChipsRipristinati
(StockTypeID,StockID,Tag,GamingDate,ValueTypeID,DenoID,Denomination,CurrencyID,Apertura)
	SELECT  
		1001 AS StockTypeID,
		1001 AS StockID,
		'Dotazione' AS Tag,
		@Gaming AS GamingDate,
		ValueTypeID,DenoID,Denomination,CurrencyID,
		SUM((Quantity) * (CASE WHEN CashInbound = 1 THEN 1 ELSE -1 END)	)		AS Amount
	FROM [Accounting].[vw_AllTransactionDenominations]
	WHERE OpTypeID = 18
	AND SourceGamingDate <= @Gaming --somma tutte le variazioni di dotazione antecedenti 
	AND DenoID NOT IN (10,95,96,97)  --forget about 500 chf and medaglie
	AND ValueTypeID = @valuetypeid

	GROUP BY ValueTypeID,DenoID,Denomination,CurrencyID


--SELECT * FROM @ChipsRipristinati

DECLARE @StockStatus TABLE (
StockTypeID INT,
StockID		INT,
Tag			VARCHAR(32),
GamingDate DATETIME
) 
INSERT INTO @StockStatus
(
    StockTypeID,
    StockID,
    Tag,
	GamingDate
)

select
	s.StockTypeID,
	s.StockID,
	s.Tag,
	lc.GamingDate
--let start from the active stocks
FROM CasinoLayout.Stocks s
INNER JOIN [Accounting].[fn_GetLastLifeCycleByStockType](@gaming,NULL) lc ON lc.StockID = s.StockID
WHERE s.StockTypeID IN (1,2,3,4,6,7) --tavoli,trolleys,cc,ms,riserva,e incasso
AND @gaming >= s.FromGamingDate 
AND (@gaming <= s.TillGamingDate OR s.TillGamingDate IS null) 

INSERT INTO @StockStatus
(
    StockTypeID,
    StockID,
    Tag,
	GamingDate
)
VALUES(
1001,1001,'Dotazione',@gaming
)
--SELECT * FROM @StockStatus


--format the last chiusura values into another temporary table

INSERT INTO @chipsreport
(
    Tag,
    StockID,
    StockTypeID,
    GamingDate,
    Chips10000,
    Chips5000,
    Chips1000,
    Chips100,
    Chips50,
    Chips25,
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
)

select 	
	s.Tag,
	s.StockID,
	s.StockTypeID,
	s.GamingDate,
	IsNull(C10000.Ripristinato,0) 	as Chips10000,
	IsNull(C5000.Ripristinato,0)	as Chips5000,
	IsNull(C1000.Ripristinato,0)	as Chips1000,
	IsNull(C100.Ripristinato,0) 	as Chips100,
	IsNull(C50.Ripristinato,0) 		as Chips50,
	IsNull(C25.Ripristinato,0) 		as Chips25,
	IsNull(C20.Ripristinato,0) 		as Chips20,
	IsNull(C10.Ripristinato,0) 		as Chips10,
	IsNull(C5.Ripristinato,0) 		as Chips5,
	IsNull(C1.Ripristinato,0) 		as Chips1,
	IsNull(LC.Ripristinato,0) 		as LuckyChips,
	IsNull(C10000.Ripristinato,0) 	* 10000 +
	IsNull(C5000.Ripristinato,0)	* 5000 +
	IsNull(C1000.Ripristinato,0)	* 1000 +
	IsNull(C100.Ripristinato,0) 	* 100 +
	IsNull(C50.Ripristinato,0) 		* 50 +
	IsNull(C25.Ripristinato,0) 		* 25 +
	IsNull(C20.Ripristinato,0) 		* 20 +
	IsNull(C10.Ripristinato,0) 		* 10 +
	IsNull(C5.Ripristinato,0) 		* 5 +
	IsNull(C1.Ripristinato,0) 		* 1 AS TotalValue
FROM @StockStatus s 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 10000	 ) C10000	ON C10000.StockID = s.StockID
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 5000	 ) C5000		ON C5000.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 1000	 ) C1000		ON C1000.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 100	 ) C100		ON C100.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 50	 ) C50		ON C50.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 25	 ) C25		ON C25.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 20	 ) C20		ON C20.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 10	 ) C10		ON C10.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 5		 ) C5		ON C5.StockID = s.StockID 
left outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where Denomination = 1		 ) C1		ON C1.StockID = s.StockID 
LEFT outer join (select StockID,(isnull(Apertura,0)) as Ripristinato from @ChipsRipristinati where DenoID = 78			 ) LC		ON LC.StockID = s.StockID 

--insert gettoni tecnici
IF @valuetypeid IN (1,42)
BEGIN


	INSERT INTO @chipsreport
	(
		Tag,
		StockID,
		StockTypeID,
		GamingDate,
		Chips10000	,
		Chips5000	,
		Chips1000,
		Chips100,
		Chips50,
		Chips25,
		Chips20,
		Chips10,
		Chips5,
		Chips1,
		LuckyChips,
		TotalValue
	)
	VALUES
	(
	'Tecnici',
	1000,
	1000,
	@gaming,
	0,--	@Chips10000		,
	0,--	@Chips5000		,
	0,--	@Chips1000		,
	20,--	@Chips100		,
	20,--	@Chips50		,
	0,--	@Chips25		,
	20,--	@Chips20		,
	20,--	@Chips10		,
	20,--	@Chips5			,
	0,--	@Chips1			,
	0,--	@LuckyChips		,
	3700--	@TotalValue		
	)
END


SELECT @Chips10000	=	SUM(CASE WHEN stockid = 1001 THEN Chips10000	ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips10000	end) FROM @chipsreport
SELECT @Chips5000	=	SUM(CASE WHEN stockid = 1001 THEN Chips5000		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips5000	end) FROM @chipsreport
SELECT @Chips1000	=	SUM(CASE WHEN stockid = 1001 THEN Chips1000		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips1000	end) FROM @chipsreport
SELECT @Chips100	=	SUM(CASE WHEN stockid = 1001 THEN Chips100		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips100		END) FROM @chipsreport
SELECT @Chips50		=	SUM(CASE WHEN stockid = 1001 THEN Chips50		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips50		end) FROM @chipsreport
SELECT @Chips25		=	SUM(CASE WHEN stockid = 1001 THEN Chips25		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips25		end) FROM @chipsreport
SELECT @Chips20		=	SUM(CASE WHEN stockid = 1001 THEN Chips20		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips20		end) FROM @chipsreport
SELECT @Chips10		=	SUM(CASE WHEN stockid = 1001 THEN Chips10		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips10		end) FROM @chipsreport
SELECT @Chips5		=	SUM(CASE WHEN stockid = 1001 THEN Chips5		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips5		end) FROM @chipsreport
SELECT @Chips1		=	SUM(CASE WHEN stockid = 1001 THEN Chips1		ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE Chips1		end) FROM @chipsreport
SELECT @LuckyChips	=	SUM(CASE WHEN stockid = 1001 THEN LuckyChips	ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE LuckyChips	end) FROM @chipsreport
SELECT @TotalValue	=	SUM(CASE WHEN stockid = 1001 THEN TotalValue	ELSE 0 end) - SUM(CASE WHEN stockid = 1001 THEN 0 ELSE TotalValue	end) FROM @chipsreport

INSERT INTO @chipsreport
(
    Tag,
    StockID,
    StockTypeID,
    GamingDate,
    Chips10000	,
    Chips5000	,
    Chips1000,
    Chips100,
    Chips50,
    Chips25,
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
)
VALUES
(
'Liability',
1002,
1002,
@gaming,
	@Chips10000		,
	@Chips5000		,
	@Chips1000		,
	@Chips100		,
	@Chips50		,
	@Chips25		,
	@Chips20		,
	@Chips10		,
	@Chips5			,
	@Chips1			,
	@LuckyChips		,
	@TotalValue		
)

INSERT INTO @ret
(
    Tag,
    StockID,
    StockTypeID,
    GamingDate,
    Chips10000,
    Chips5000,
    Chips1000,
    Chips100,
    Chips50,
    Chips25,
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
)
SELECT     Tag,
    StockID,
    StockTypeID,
    GamingDate,
    Chips10000,
    Chips5000,
    Chips1000,
    Chips100,
    Chips50,
    Chips25,
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
FROM @chipsreport
RETURN

END
GO
