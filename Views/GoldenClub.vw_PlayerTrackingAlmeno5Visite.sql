SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [GoldenClub].[vw_PlayerTrackingAlmeno5Visite]
AS
SELECT pt.[CustomerID],
		c.LastName,
		c.FirstName,
		m.GoldenClubCardID,
		mt.FDescription AS MemberType
      ,COUNT([TotIngressi]) AS Visite --somma i giorni con visite
      ,SUM([CountEuroIn]) + SUM([CountEuroOut]) AS quantiCambiEuro
      ,SUM([CountRegIn]) + SUM([CountRegOut]) AS quanteRegistrazioni
      ,SUM([CountAss]) AS quantiAssegni
      ,SUM([CountCC]) AS QuanteCC
  FROM [GoldenClub].[tbl_PlayerTracking] pt
  INNER JOIN Snoopy.tbl_Customers c ON pt.CustomerID = c.CustomerID
  LEFT OUTER JOIN GoldenClub.tbl_Members m ON pt.CustomerID = m.CustomerID
  LEFT OUTER JOIN GoldenClub.tbl_MemberTypes mt ON mt.MemberTypeID = m.MemberTypeID
  WHERE Gamingdate >= '1.1.2017'
  GROUP BY pt.[CustomerID],c.LastName,c.FirstName,m.GoldenClubCardID,mt.FDescription
  HAVING COUNT([TotIngressi]) > 5
AND 
(
SUM([CountEuroIn]) + SUM([CountEuroOut]) IS NOT NULL
OR 
SUM([CountRegIn]) + SUM([CountRegOut]) IS NOT NULL
OR SUM([CountAss]) IS NOT NULL
OR SUM([CountCC]) IS NOT NULL
)
--order by c.LastName,c.FirstName

GO
