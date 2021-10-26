SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE FUNCTION [Accounting].[fn_PerEuroBox] (
@gaming			DATETIME,
@stockid		INT
)  
RETURNS FLOAT
WITH SCHEMABINDING
AS  
BEGIN 
	DECLARE @percEURBox FLOAT


	SELECT --a.Dal,a.Al,a.giorni,a.TotalEUR,a.TotalCHF,a.TotalEUR / (a.TotalCHF + a.TotalEUR) AS EuroPerc
		@percEURBox = (a.TotalEUR)  / ((a.TotalCHF) + (a.TotalEUR))
	FROM
	(
		SELECT 	
			MIN([GamingDate]) AS Dal
			,MAX([gamingDate]) AS Al
			,LEFT(Tag,2) AS TableType
			,count(DISTINCT GamingDate) AS giorni
			,SUM( CASE WHEN CurrencyID = 0 THEN Quantity * Denomination ELSE 0 end) AS TotalEUR
			,SUM( CASE WHEN CurrencyID = 4 THEN Quantity * Denomination ELSE 0 end) AS TotalCHF
		 
		FROM [Accounting].[vw_AllConteggiDenominations]
		WHERE SnapshotTypeID = 7 --conteggio cash box tavoli
		AND GamingDate > DATEADD(MONTH,-3,@gaming) --in the last 6 moths
		AND DATEPART(WEEKDAY,GamingDate) = DATEPART(WEEKDAY,@gaming) --count onla the same week day
		GROUP BY  LEFT(Tag,2)
	)a 
	INNER JOIN CasinoLayout.Stocks st ON LEFT(st.Tag,2) = a.TableType
	WHERE st.StockID = @stockID

	IF @percEURBox IS NULL
		SET @percEURBox = 0.0

	RETURN @percEURBox
END




GO
