SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [Accounting].[usp_ChipsReportEx]
@gaming			DATETIME,
@valuetypeid	INT,
@absolute		INT
AS

IF NOT @valuetypeid IN (1,36,42,59,100)
BEGIN
	raiserror('Must specify ValuetypeID 1,36 or 42',16,-1)
	return (1)	
END
/*
DECLARE @gaming DATETIME,@valuetypeid INT
SET @gaming = '12.31.2021'
SET @valuetypeid = 59

execute [Accounting].[usp_ChipsReportEx]
@gaming			,
@valuetypeid	,
1
--*/
DECLARE @sql NVARCHAR(MAX)
IF @valuetypeid = 100
BEGIN
	--sum up chips chf and chips gioco euro
	DECLARE @chipsreportchf TABLE
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
	DECLARE @chipsreportgiocoeuro TABLE
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

	IF @absolute = 0
	BEGIN 
		INSERT INTO @chipsreportchf
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
		select Tag,
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
		FROM [Accounting].[fn_ChipsReportDailyIncrement] (@gaming,1)

		INSERT INTO @chipsreportgiocoeuro
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
		select Tag,
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
		FROM [Accounting].[fn_ChipsReportDailyIncrement] (@gaming,36)
	END
	ELSE
	BEGIN
		INSERT INTO @chipsreportchf
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
		select Tag,
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
		FROM [Accounting].[fn_ChipsReportAbsolute] (@gaming,1)

		INSERT INTO @chipsreportgiocoeuro
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
		select Tag,
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
		FROM [Accounting].[fn_ChipsReportAbsolute] (@gaming,36)
	END
	    

	SELECT 
			c.Tag,
			c.GamingDate,
			c.Chips10000	+ e.Chips10000	AS Chips10000	,
			c.Chips5000		+ e.Chips5000	AS Chips5000	,
			c.Chips1000		+ e.Chips1000	AS Chips1000	,
			c.Chips100		+ e.Chips100	AS Chips100		,
			c.Chips50		+ e.Chips50		AS Chips50		,
			c.Chips20		+ e.Chips20		AS Chips20		,
			c.Chips10		+ e.Chips10		AS Chips10		,
			c.Chips5		+ e.Chips5		AS Chips5		,
			c.Chips1		+ e.Chips1		AS Chips1		,
			c.LuckyChips	+ e.LuckyChips	AS LuckyChips	,
			c.TotalValue	+ e.TotalValue	AS TotalValue	
	FROM @chipsreportchf c 
	INNER JOIN @chipsreportgiocoeuro e ON e.StockID = c.StockID
	ORDER BY c.StockTypeID,	c.StockID

END
ELSE
BEGIN
	/*
DECLARE @gaming DATETIME,@valuetypeid INT,@sql nvarchar(max)
SET @gaming = '12.31.2021'
SET @valuetypeid = 1
--*/
	SET @sql =
		'SELECT          	 ' +
		'	c.Tag,			 ' +
		'	c.GamingDate,	 ' +
		CASE WHEN @valuetypeid NOT IN(59) THEN '	c.Chips10000,'  ELSE '' END +
		CASE WHEN @valuetypeid NOT IN(59) THEN '	c.Chips5000,'  ELSE '' END +
		'	c.Chips1000,	 ' +
		'	c.Chips100,		 ' +
		CASE WHEN @valuetypeid NOT IN(59) THEN '	c.Chips50,'  ELSE '' END +
		CASE WHEN @valuetypeid IN(1,59) THEN ' c.Chips25,' ELSE '' END +
		CASE WHEN @valuetypeid NOT IN(59) THEN '	c.Chips20,'  ELSE '' END +
		CASE WHEN @valuetypeid NOT IN(59) THEN '	c.Chips10,'  ELSE '' END +
		'	c.Chips5,		 ' +
		'	c.Chips1,		 ' +
		CASE WHEN @valuetypeid IN(1) THEN '	c.LuckyChips,'  ELSE '' END +
		'	c.TotalValue 	 ' +
		CASE 
			WHEN @absolute = 0 
			THEN 'FROM [Accounting].[fn_ChipsReportDailyIncrement] (''' 
			ELSE 'FROM [Accounting].[fn_ChipsReportAbsolute] (''' 
		END +
		CONVERT(NVARCHAR(28),@gaming,23) + ''', ' 
		+ CAST(@valuetypeid AS VARCHAR(32)) + ') c' +
		' ORDER BY c.StockTypeID,	c.StockID'
	EXEC sp_executeSQL @SQL			
END

RETURN 0


GO
GRANT EXECUTE ON  [Accounting].[usp_ChipsReportEx] TO [SolaLetturaNoDanni]
GO
