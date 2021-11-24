SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Marketing].[vw_LuckyChipsControllo]
AS
SELECT ISNULL(c.[GamingDate],k.Gamingdate) AS Gamingdate
      ,c.[TotLucky20]
      ,c.[TotPezzi]			AS TotPezziConsegnati
      ,c.[TotValue]			AS TotValueConsegnati
	  ,cas.UscitaCasse		AS TotPezziCassa
      ,k.[LuckChipsPezzi]	AS TotPezziContati
      ,k.[LuckChipsValue]	AS TotValueContati

  FROM [Marketing].[vw_LuckyConsegnate] c
  FULL OUTER JOIN [Marketing].[vw_LuckChipsContate] k ON c.Gamingdate = k.Gamingdate
  FULL OUTER JOIN 
  (
	  SELECT [GamingDate]
		  ,SUM(ISNULL([InitialQty] - Chiusura,0)) AS UscitaCasse
	  FROM [Alamo].[Accounting].[vw_AllChiusuraConsegnaDenominations]
	  WHERE DenoID = 78 AND StockTypeID IN (4,7)
	  GROUP BY GamingDate
 ) cas ON cas.Gamingdate = k.Gamingdate

GO
