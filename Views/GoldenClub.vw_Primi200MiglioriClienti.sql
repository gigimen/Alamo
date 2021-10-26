SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [GoldenClub].[vw_Primi200MiglioriClienti]
AS
   SELECT TOP 200 
      g.[CustomerID]
	  ,c.LastName
	  ,c.FirstName
	  ,g.Categoria
	  ,s.SectorName
  FROM GoldenClub.tbl_Members g
  INNER JOIN Snoopy.tbl_Customers c ON c.CustomerID = g.CustomerID
  INNER JOIN CasinoLayout.Sectors s ON s.SectorID = g.SectorID
  WHERE g.CancelID IS NULL --non ha rinunciato
  ORDER BY g.Categoria ASC








GO
