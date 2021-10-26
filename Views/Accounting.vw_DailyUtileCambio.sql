SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Accounting].[vw_DailyUtileCambio]
AS

SELECT c.Gamingdate,c.IntRate,c.ExtRate
, CAST(u.Utile AS FLOAT) /100.0 AS UtileCambioCHF
, CAST(o.Utile AS FLOAT) /100.0 * c.IntRate AS CommissioniCHF
FROM 
(
	SELECT c.GamingDate,IntRate,c.ExtRate	
	FROM   Accounting.tbl_CurrencyGamingdateRates c
	WHERE c.CurrencyID = 0
) c left OUTER JOIN
(
	SELECT ValueTypeID,ValueTypeName,SUM(Consegna) AS Utile,gamingdate
	FROM Accounting.vw_AllChiusuraConsegnaDenominations e 
	WHERE StockTypeID IN(4,7) 
	AND ValueTypeID IN(32)
	GROUP BY ValueTypeID,ValueTypeName,gamingdate
)u ON u.GamingDate = c.GamingDate
left OUTER JOIN
(
	SELECT ValueTypeID,ValueTypeName,SUM(Consegna) AS Utile,gamingdate
	FROM Accounting.vw_AllChiusuraConsegnaDenominations e 
	WHERE StockTypeID IN(4,7) 
	AND ValueTypeID IN(52)
	GROUP BY ValueTypeID,ValueTypeName,gamingdate
)o ON o.GamingDate = c.GamingDate
GO
