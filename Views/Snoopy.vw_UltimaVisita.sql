SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Snoopy].[vw_UltimaVisita]
AS
SELECT [CustomerID]
      ,MAX([GamingDate])				AS UltimoGamingDate
	  ,MAX(entratatimestampLoc)			AS UtimaOra
      ,COUNT(DISTINCT gamingdate)		AS TotVisite
  FROM Reception.tbl_CustomerIngressi
  GROUP BY CustomerID
GO
