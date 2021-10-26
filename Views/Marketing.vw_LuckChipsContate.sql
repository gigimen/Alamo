SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Marketing].[vw_LuckChipsContate]
AS
SELECT 
	Gamingdate,
	SUM(TotCount) AS LuckChipsPezzi,
	SUM(TotCount) * 5 AS LuckChipsValue
FROM [Accounting].[vw_TableLuckyChipsContato]
GROUP BY GamingDate
GO
