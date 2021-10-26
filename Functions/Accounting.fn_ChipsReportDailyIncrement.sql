SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE     FUNCTION [Accounting].[fn_ChipsReportDailyIncrement]
(
@gaming DATETIME,
@valuetypeid INT
)
/*
select * from [Accounting].[fn_ChipsReport] ('8.30.2020',1)
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
SET @gaming = '8.30.2020'
SET @valuetypeid = 100



--*/

DECLARE @yea TABLE
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
DECLARE @today TABLE
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

INSERT INTO @today
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
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
)
SELECT
    Tag,
    StockID,
    StockTypeID,
    GamingDate,
    Chips10000,
    Chips5000,
    Chips1000,
    Chips100,
    Chips50,
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
FROM Accounting.fn_ChipsReportAbsolute(@gaming,@valuetypeid)


INSERT INTO @yea
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
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
)
SELECT
    Tag,
    StockID,
    StockTypeID,
    GamingDate,
    Chips10000,
    Chips5000,
    Chips1000,
    Chips100,
    Chips50,
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
FROM Accounting.fn_ChipsReportAbsolute(DATEADD(DAY,-1,@gaming),@valuetypeid)


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
    Chips20,
    Chips10,
    Chips5,
    Chips1,
    LuckyChips,
    TotalValue
)
SELECT     
	t.Tag,
    t.StockID,
    t.StockTypeID,
    t.GamingDate,
    t.Chips10000	- y.Chips10000,
    t.Chips5000		- y.Chips5000,
    t.Chips1000		- y.Chips1000,
    t.Chips100		- y.Chips100,
    t.Chips50		- y.Chips50,
    t.Chips20		- y.Chips20,
    t.Chips10		- y.Chips10,
    t.Chips5		- y.Chips5,
    t.Chips1		- y.Chips1,
    t.LuckyChips	- y.LuckyChips,
    t.TotalValue	- y.TotalValue
FROM @today t 
INNER JOIN @yea y ON y.StockID = t.StockID

RETURN

END
GO
