SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Marketing].[vw_LuckyChipsControllo]
as
SELECT ISNULL(c.[GamingDate],k.Gamingdate) AS Gamingdate
      ,c.[TotLucky20]
      ,c.[TotPezzi]			AS TotPezziConsegnati
      ,c.[TotValue]			AS TotValueConsegnati
      ,k.[LuckChipsPezzi]	AS TotPezziContati
      ,k.[LuckChipsValue]	AS TotValueContati

  FROM [Alamo].[Marketing].[vw_LuckyConsegnate] c
  FULL OUTER JOIN [Marketing].[vw_LuckChipsContate] k ON c.Gamingdate = k.Gamingdate

GO
